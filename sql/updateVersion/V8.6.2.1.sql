DROP PROCEDURE IF EXISTS `DelColumn`;
delimiter ||
CREATE  PROCEDURE `DelColumn`(
	tablename varchar(50),
	columnname varchar(50)
)
begin

	select database() into @tableschema;

	set tablename=lower(tablename);
	set @colName='';
	SET @tsql=CONCAT('select  IFNULL(column_name, '''') into @colName  from information_schema.columns where  TABLE_SCHEMA =','''',@tableschema,'''','  and  table_name= ','''',tablename,'''',' and COLUMN_NAME=','''',columnname,'''');

	prepare stmt from @tsql;
	execute stmt;

	set @coldel=IFNULL(@colName,'-1');

	IF @coldel <> '-1'  and  @coldel=columnname THEN

		set @alterColumn=CONCAT(' alter table ',tablename, ' drop ',columnname);
		prepare stalter from @altercolumn;
		execute stalter;
		deallocate prepare stalter;
	END IF;

	deallocate prepare stmt;

end ||
delimiter;

CREATE TABLE if not EXISTS `ld_advanceprocess` (
	`stageid` int(11) NOT NULL AUTO_INCREMENT,
	`nodeid` int(11) DEFAULT NULL,
	`childid` text,
	`branchnodeid` int(11) DEFAULT NULL,
	`nodetype` varchar(30) DEFAULT NULL,
	`nodename` varchar(100) DEFAULT NULL,
	`frommodule` varchar(100) DEFAULT NULL,
	`fieldname` varchar(100) DEFAULT NULL,
	`stagename` varchar(100) DEFAULT NULL,
	`content` text DEFAULT NULL,
	`createdtime` datetime DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (`stageid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

call AddColumn('ld_settings_advance','defaultshow','varchar','20',null);
delimiter;

drop PROCEDURE  if EXISTS set_defualt_advance_process;
delimiter ||
create PROCEDURE set_defualt_advance_process()
BEGIN
	declare var_fieldname varchar(100);
	declare var_module varchar(100);
	declare done  int  default 0;
	
	declare cur1 CURSOR FOR SELECT module,module_field from ld_settings_advance where method = 'field' AND module IN (SELECT name FROM ld_tab);
	declare continue handler for not found SET done =1;	
	
	open cur1;
	Fetch cur1 into var_module,var_fieldname;
	loop1: while  done<>1 DO
				set @tabid = (SELECT tabid from ld_tab where `name` = var_module);
				if not EXISTS(SELECT 1 from ld_advanceprocess where frommodule = var_module and fieldname = var_fieldname) THEN
					set @listid = (SELECT listid from ld_picklist_set where listname = var_fieldname and relatetable = 'ld_field' limit 1);
					if @listid >0 then 
						
						INSERT into ld_advanceprocess(nodeid,childid,branchnodeid,nodetype,nodename,frommodule,fieldname,stagename) 
							values(-1,1,-1,'start','开始',var_module,var_fieldname,'');
						set @i = 0;
						INSERT into ld_advanceprocess(nodeid,childid,branchnodeid,nodetype,nodename,frommodule,fieldname,stagename) 
						SELECT (@i:=@i+1),@i+1,-1,'approver',CONCAT('步骤',@i),var_module,var_fieldname,listvalue
						from ld_picklist_values where listid = @listid ORDER BY sequence;
						
						set @max_stageid = (SELECT max(stageid) from ld_advanceprocess where frommodule = var_module and fieldname = var_fieldname);
						UPDATE ld_advanceprocess set childid = '' where stageid = @max_stageid;

						if not EXISTS(SELECT 1 from ld_advancepicklist where tabid = @tabid and fieldname = var_fieldname) THEN
							call set_defualt_advance_relation(@tabid,var_fieldname,@listid);
						end if;
					end if;
				end if;

				Fetch cur1 into var_module,var_fieldname;
	end while loop1;
	close cur1;
end ||
delimiter;

drop PROCEDURE  if EXISTS set_defualt_advance_relation;
delimiter ||
create PROCEDURE set_defualt_advance_relation
(
var_tabid int(11),var_fieldname varchar(100),var_listid int(11)
)
BEGIN
	declare var_stagevalue VARCHAR(100);
	declare done  int  default 0;
	
	declare cur1 CURSOR FOR SELECT listvalue from ld_picklist_values where listid = var_listid ORDER BY sequence;
	declare continue handler for not found SET done =1;	
	
	set @pre_value = '';
	open cur1;
	Fetch cur1 into var_stagevalue;
	loop1: while  done<>1 DO
				if @pre_value <> '' then
						insert into ld_advancepicklist(tabid,fieldname,stagename,stagename_target,presence) values(var_tabid,var_fieldname,@pre_value,var_stagevalue,'yes');
				end if;

				set @pre_value = var_stagevalue;
				Fetch cur1 into var_stagevalue;
	end while loop1;
	close cur1;
end ||
delimiter;

call set_defualt_advance_process();
drop PROCEDURE  if EXISTS set_defualt_advance_process;
drop PROCEDURE  if EXISTS set_defualt_advance_relation;
delimiter;


SET @labelbol = 'STEPNAME';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'步骤名称',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Step name',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'DETAILPAGESHOWTYPE';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'详情页默认展开',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Default expansion of detail page',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'NOTALLOWEDTOCONTINUEADVANCING';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'提示：所有条件都不满足时，不允许继续向后推进',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Tip: When all conditions are not met, it is not allowed to continue advancing backwards',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;


SET @labelbol = 'BASICINFORMATION';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'基本信息',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Basic information',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'CURRENTSTAGE';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'当前阶段',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Current stage',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'SETSTEPINFORMATION';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请设置步骤信息',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please set step information',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'addcondition';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'添加条件',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Add condition',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'ConditionBranch';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'条件分支',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Condition branch',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'endworkflow';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'流程结束',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'End flow',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'STEPNAME';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'步骤名称',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Step name',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'STEP';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'步骤',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Step',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'SHOWADVANCEDETAIL';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'点击查看推进详情',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Click to show advance detail',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'DRAGTORIGHTSTEP';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'可将此处的下拉框选项拖动到右侧的步骤中,每个选项只能使用一次',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'You can drag the dropdown options here to the steps on the right, each option can only be used once',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'ADDDEFAULTPROCESS';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'是否需要添加默认流程？',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Do you need to add a default process?',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'STEPINFORMATIONCANNOTEMPTY';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'步骤信息不能为空！',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Step information can not be empty!',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'NOAVAILABLEDROPDOWNOPTIONS';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'没有可用的下拉框选项',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No available dropdown options',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'STAGEVALUEISINCORRECT';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'当前阶段值错误，添加开始步骤，并允许流转到第一个步骤',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The current stage value is incorrect. Add a start step to allow the flow to proceed to the first step.',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;


update  ld_customreport_chartset set legend_position='righttop' where ifnull(legend_position,'')='';
delimiter;

select deploy_value into @content from ld_systems_deploy where deploy_type = 280;
insert into ld_module_setting_byuser(modulename,userid,label,content)
select 'Accounts',1,'DuplicateCheckShowHyperLink',@content
from dual where not exists(select 1 from ld_module_setting_byuser where label='DuplicateCheckShowHyperLink' and modulename='Accounts');
delimiter;

select deploy_value into @content from ld_systems_deploy where deploy_type = 326;
insert into ld_module_setting_byuser(modulename,userid,label,content)
select 'Potentials',1,'DuplicateCheckShowHyperLink',@content
from dual where not exists(select 1 from ld_module_setting_byuser where label='DuplicateCheckShowHyperLink' and modulename='Potentials');
delimiter;

select deploy_value into @content from ld_systems_deploy where deploy_type = 327;
insert into ld_module_setting_byuser(modulename,userid,label,content)
select 'Products',1,'DuplicateCheckShowHyperLink',@content
from dual where not exists(select 1 from ld_module_setting_byuser where label='DuplicateCheckShowHyperLink' and modulename='Products');
delimiter;

insert into ld_module_setting_byuser(modulename,userid,label,content)
select 'Leads',1,'DuplicateCheckShowHyperLink',0
from dual where not exists(select 1 from ld_module_setting_byuser where label='DuplicateCheckShowHyperLink' and modulename='Leads');
delimiter;

insert into ld_module_setting_byuser(modulename,userid,label,content)
select 'Vendors',1,'DuplicateCheckShowHyperLink',0
from dual where not exists(select 1 from ld_module_setting_byuser where label='DuplicateCheckShowHyperLink' and modulename='Vendors');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Vendors');
SET @actionid=(SELECT actionid FROM ld_actionmapping where actionname = 'accountdatadup' AND actionlabel='ACCOUNTDUPLICATECHECK');
SET @beforeactionid=(SELECT actionid FROM ld_actionmapping where actionname = 'Delete');
SET @new_seq=IFNULL((SELECT IFNULL(sequence,0) FROM ld_profileallpermission where tabid=@tabid and operation = @beforeactionid),0);
INSERT INTO ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,@actionid,@new_seq FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid =@tabid AND operation=@actionid)
	AND @tabid>0;
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Vendors');
SET @actionid=(SELECT actionid FROM ld_actionmapping where actionname = 'Merge' AND actionlabel='Merge');
SET @beforeactionid=(SELECT actionid FROM ld_actionmapping where actionname = 'Export');
SET @new_seq=IFNULL((SELECT IFNULL(sequence,0) FROM ld_profileallpermission where tabid=@tabid and operation = @beforeactionid),0);
INSERT INTO ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,@actionid,@new_seq FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid =@tabid AND operation=@actionid)
	AND @tabid>0;
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Vendors');
SET @actionid=(SELECT actionid FROM ld_actionmapping where actionname = 'dup_and_merge' AND actionlabel='CHECKMERGE');
SET @beforeactionid=(SELECT actionid FROM ld_actionmapping where actionname = 'CustomView');
SET @new_seq=IFNULL((SELECT IFNULL(sequence,0) FROM ld_profileallpermission where tabid=@tabid and operation = @beforeactionid),0);
INSERT INTO ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,@actionid,@new_seq FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid =@tabid AND operation=@actionid)
	AND @tabid>0;
delimiter;

SET @i = 0;
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Vendors');
update ld_profileallpermission set sequence=(@i:=@i+1) where tabid=@tabid AND @tabid>0 ORDER BY sequence;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_profile_for_default_vendors_dup_20231219`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_profile_for_default_vendors_dup_20231219`(in `tmp_tabname` varchar(50) , in `tmp_actionname` varchar(200))
BEGIN

	DECLARE tmp_profileid INT(19) DEFAULT 0;
	DECLARE MYCUSOR CURSOR FOR SELECT profileid FROM ld_profile WHERE profileid>0;
DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_profileid = NULL;
	SET @tabid=(select tabid from ld_tab  where name=`tmp_tabname`);
	set @operation = (SELECT actionid from ld_actionmapping where actionname = `tmp_actionname`);

IF NOT EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE tabid=@tabid and operation = @operation) AND @tabid>0 THEN OPEN MYCUSOR;
FETCH MYCUSOR INTO tmp_profileid;
WHILE(tmp_profileid IS NOT NULL) DO

	SET @profileid=tmp_profileid;
INSERT INTO ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
SELECT @profileid AS profileid,@tabid AS tabid,@operation,0,0 FROM dual
WHERE not exists(select 1 from ld_profile2standardpermissions where tabid=@tabid and operation=@operation and profileid=@profileid) LIMIT 1;

FETCH MYCUSOR INTO tmp_profileid;
END WHILE;
CLOSE MYCUSOR;
END IF;
END ||
delimiter;

CALL ldcrm_add_profile_for_default_vendors_dup_20231219('Vendors','accountdatadup');
CALL ldcrm_add_profile_for_default_vendors_dup_20231219('Vendors','Merge');
CALL ldcrm_add_profile_for_default_vendors_dup_20231219('Vendors','dup_and_merge');
DROP PROCEDURE IF EXISTS `ldcrm_add_profile_for_default_vendors_dup_20231219`;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SHARE','分享','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SHARE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SHARE',"Share",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SHARE' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SELECTREVIEWERS','选择点评人','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SELECTREVIEWERS' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SELECTREVIEWERS',"Select reviewers",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SELECTREVIEWERS' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype)
SELECT 'zh','pleaseselectdate','请选择日期','fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'pleaseselectdate' AND labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','pleaseselectdate','Please select date','fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'pleaseselectdate' AND labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','COMMENTCONTENT','点评内容','jspop'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'COMMENTCONTENT' AND labeltype = 'jspop');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','COMMENTCONTENT','Comment content','jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'COMMENTCONTENT' AND labeltype = 'jspop');
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','Reply','回复','jspop'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'Reply' AND labeltype = 'jspop');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','Reply','Reply','jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'Reply' AND labeltype = 'jspop');
delimiter;

UPDATE ld_module_setting_byuser set content = 20 where label = 'MaxEntriesPerPage' and content = 'undefined';  
delimiter;

UPDATE ld_tranlabel SET fieldlabel='设置计算已开票金额时是否统计未审批的{$Invoice.Invoice}和{$PurchaseInvoice.PurchaseInvoice}' WHERE trantable='ld_systems_deploy' AND Relateid=463 AND languagetype='zh';
-- 2023-12-31

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT 'zh','USERSCANCHOOSE','可选择成员', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'USERSCANCHOOSE' AND labeltype = 'jspop' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT 'en','USERSCANCHOOSE','Users can choose', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'USERSCANCHOOSE' AND labeltype = 'jspop' );
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT 'zh','USERHASSELECTED','已选择成员', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'USERHASSELECTED' AND labeltype = 'jspop' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT 'en','USERHASSELECTED','User has selected', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'USERHASSELECTED' AND labeltype = 'jspop' );
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TargetRangeMappingField','目标范围映射字段','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TargetRangeMappingField' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TargetRangeMappingField','Target Range Mapping Field','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TargetRangeMappingField' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TimeRangeMappingField','时间范围映射字段','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TimeRangeMappingField' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TimeRangeMappingField','Time Range Mapping Field','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TimeRangeMappingField' and Labeltype='fixedstr' and languagetype='en');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_listview_btn` (
    `id` int(11)  NOT NULL AUTO_INCREMENT,
    `name` varchar(255) DEFAULT NULL COMMENT '按钮名称',
    `btntype` varchar(100) DEFAULT NULL COMMENT '按钮类型self为独立按钮，rely为依赖按钮',
    `description` text COMMENT '描述',
    `iconname` varchar(100) COMMENT '按钮icon名称',
    PRIMARY KEY (`id`)  USING BTREE
    ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'Create','self','新增','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'Create');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'Import','self','导入','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'Import');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'Export','self','导出','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'Export');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'ElectronicSignature','self','电子签章','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'ElectronicSignature');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'ModuleTreeSettings','self','树结构设置','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'ModuleTreeSettings');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'Approvalsettings','self','审批设置','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'Approvalsettings');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'ResetListWidth','self','恢复默认列宽','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'ResetListWidth');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'leadsaccountset','self','公海参数设置','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'leadsaccountset');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'DataScope','self','数据范围','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'DataScope');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'allowedituserfield','self','设置全部普通成员可编辑的字段','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'allowedituserfield');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'CreateDebuction','self','预收','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'CreateDebuction');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'CreateCashBill','self','收款','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'CreateCashBill');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'basicBudget','self','','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'basicBudget');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'salesGoalBudget','self','','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'salesGoalBudget');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'salesAchievementBudget','self','','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'salesAchievementBudget');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'textArticles','self','','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'textArticles');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'imageArticles','self','','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'imageArticles');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'linkArticles','self','','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'linkArticles');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'PDFArticles','self','','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'PDFArticles');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'Findduplicates','self','查重','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'Findduplicates');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'Recalculation_latandlong','rely','重算经纬度','Recalculation_latandlong.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'Recalculation_latandlong');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'Settings','self','页面设置','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'Settings');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'sms_settings','self','短信设置','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'sms_settings');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'SMS1','self','合同订单-短信1','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'SMS1');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'SMS2','self','合同订单-短信2','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'SMS2');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'SMS3','self','合同订单-短信3','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'SMS3');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'howTosendpayment','self','付款计划-如何创建付款计划','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'howTosendpayment');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'howTopayment','self','回款计划-如何创建回款计划','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'howTopayment');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'howToservicereturn','self','服务回访单-如何创建服务回访单','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'howToservicereturn');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'howToquoteschange','self','如何创建','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'howToquoteschange');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'howTobudgetchange','self','如何创建','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'howTobudgetchange');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'HowToMainTran','self','如何创建','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'HowToMainTran');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'howTodevidend','self','如何创建','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'howTodevidend');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'howToCashBack','self','如何创建','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'howToCashBack');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'howToPurchaseCashBack','self','如何创建','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'howToPurchaseCashBack');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'howToPurchaseReturn','self','如何创建','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'howToPurchaseReturn');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'salesbackhowtogoods','self','如何创建','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'salesbackhowtogoods');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'dividend_rules','self','提醒:删除所有','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'dividend_rules');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'bw_helpdesk','self','同步帮我吧','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'bw_helpdesk');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'Settlement','self','','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'Settlement');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'ExportCustomsOrder','self','','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'ExportCustomsOrder');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'ExportCheckTemplate','self','','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'ExportCheckTemplate');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'ExportCustomsOrderEmail','self','','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'ExportCustomsOrderEmail');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'LangJieLocalAssign','self','','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'LangJieLocalAssign');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'UserLoginControl','self','登录控制','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'UserLoginControl');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'UnlockUserAccount','self','解锁账号','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'UnlockUserAccount');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'Shopsettings','self','购物车','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'Shopsettings');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'Datadupcheck','self','','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'Datadupcheck');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'ElectronicSignature','self','电子签章  访问后台，创建连接','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'ElectronicSignature');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'Businessquerysettings','self','','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'Businessquerysettings');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'opencart','self','','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'opencart');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'AddressbookSync','self','企业微信通讯录及部门同步','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'AddressbookSync');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'OffiaccountUser','self','同步微信公众号用户','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'OffiaccountUser');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'BaxterImport','self','百特导入','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'BaxterImport');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'CF54massget','self','中司证书模块领取','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'CF54massget');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'Allocate','rely','分配','Allocate.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'Allocate');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'Delete','rely','删除','Delete.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'Delete');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'submitapprove','rely','批量审批','submitapprove.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'submitapprove');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'Share','rely','共享','Share.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'Share');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'mass_edit','rely','批量编辑','mass_edit.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'mass_edit');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'ContinuousDialing','rely','自动拨号','ContinuousDialing.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'ContinuousDialing');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'DownloadSelected','rely','下载全部附件','DownloadSelected.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'DownloadSelected');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'ChangeCreator','rely','更改创建人','ChangeCreator.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'ChangeCreator');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'discontinued','rely','禁用（产品）','discontinued.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'discontinued');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 's_mail','rely','群发邮件','s_mail.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 's_mail');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 's_sms','rely','群发短信','s_sms.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 's_sms');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 's_sms_vioce','rely','群发语音','s_sms_vioce.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 's_sms_vioce');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'GroupSetUser','rely','部门设置','GroupSetUser.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'GroupSetUser');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'leadsnoallocateconvertnormal','rely','变更公海','leadsnoallocateconvertnormal.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'leadsnoallocateconvertnormal');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'noallocateconvertnormal','rely','变更公海','noallocateconvertnormal.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'noallocateconvertnormal');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'leadsaverageDistribution','rely','平均分配','leadsaverageDistribution.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'leadsaverageDistribution');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'leadsmassget','rely','领取','leadsmassget.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'leadsmassget');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'leadsmassrelease','rely','批量释放','leadsmassrelease.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'leadsmassrelease');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'leadsaveragehigndistribution','rely','平均分配','leadsaveragehigndistribution.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'leadsaveragehigndistribution');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'leadshigndistribution','rely','公海分配','leadshigndistribution.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'leadshigndistribution');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'reCalculationBudget','rely','重算预算金额','reCalculationBudget.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'reCalculationBudget');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'rate_recalculate','rely','利息重算','rate_recalculate.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'rate_recalculate');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'distribution','rely','分配','distribution.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'distribution');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 's_dividend','rely','批量派息','s_dividend.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 's_dividend');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 's_dividend','rely','批量派息','s_dividend.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 's_dividend');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'averageDistribution','rely','平均分配','averageDistribution.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'averageDistribution');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'batchapprove','rely','批量审批','batchapprove.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'batchapprove');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'resubmitapprove','rely','重新提交','resubmitapprove.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'resubmitapprove');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'RecordMerge','rely','合并','RecordMerge.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'RecordMerge');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'BatchBackFilling','rely','批量回填','BatchBackFilling.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'BatchBackFilling');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'mark','rely','提醒-设为已读','mark.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'mark');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'unmark','rely','提醒-设为未读','unmark.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'unmark');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'Updatestate','rely','更改审批状态','Updatestate.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'Updatestate');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'specialfield_edit','rely','更改订单信息','specialfield_edit.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'specialfield_edit');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'massSendCashBill','rely','付款计划-批量付款','massSendCashBill.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'massSendCashBill');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'massCashBill','rely','回款计划-批量收款','massCashBill.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'massCashBill');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'MergeCreate','rely','合并创建','MergeCreate.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'MergeCreate');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'price_strategy','rely','定价策略','price_strategy.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'price_strategy');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'discontinued','rely','','discontinued.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'discontinued');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'Batchonshelves','rely','','Batchonshelves.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'Batchonshelves');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'Revenueplan','rely','','Revenueplan.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'Revenueplan');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'ContinuousDialing','rely','连续拨号 灵当录音盒','ContinuousDialing.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'ContinuousDialing');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'addtocart','rely','加入购物车','addtocart.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'addtocart');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'receive','rely','领取工单','receive.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'receive');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'recalculate','rely','','recalculate.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'recalculate');

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'Update_addresss','rely','咨询认证行业crm重算地址','Update_addresss.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'Update_addresss');
delimiter;

SET @labelbol = 'Listtool';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'列表工具',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'List tool',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'Generalbuttonsorting';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'通用按钮排序',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'General button sorting',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'Batchoperationbuttonsorting';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'批量操作按钮排序',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Batch operation button sorting',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CalendarSettings','日历设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CalendarSettings' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CalendarSettings',"Calendar Settings",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CalendarSettings' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CalendarSettings','日历设置','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CalendarSettings' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CalendarSettings',"Calendar Settings",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CalendarSettings' and labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MessageNotificationSettings','消息通知设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MessageNotificationSettings' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MessageNotificationSettings',"Message notification settings",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MessageNotificationSettings' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DefaultValueSettings','默认值设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DefaultValueSettings' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DefaultValueSettings',"Default value settings",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DefaultValueSettings' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CalendarDefaultDisplay','日历默认显示','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CalendarDefaultDisplay' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CalendarDefaultDisplay',"Calendar default display",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CalendarDefaultDisplay' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DefaultStartTime','默认起始时间点','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DefaultStartTime' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DefaultStartTime',"Default start time",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DefaultStartTime' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TimeSlotDurationDefault','时间槽时长默认','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TimeSlotDurationDefault' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TimeSlotDurationDefault',"Time slot duration Default",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TimeSlotDurationDefault' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','minutes','分钟','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='minutes' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','minutes'," minute",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='minutes' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OCLOCK','点','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='OCLOCK' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','OCLOCK'," o'clock",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='OCLOCK' and labeltype='fixedstr');
delimiter;
update ld_desk set fieldlabel = '显示跟进记录下次回访日期提醒' where languagetype = 'zh' and labelbol = 'ContactRecordsRemind' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Display a follow-up record of the next visit date reminders' where languagetype = 'en' and labelbol = 'ContactRecordsRemind' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = '显示合同订单交付日期提醒' where languagetype = 'zh' and labelbol = 'SalesOrderRemind' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Display contract order delivery date reminders' where languagetype = 'en' and labelbol = 'SalesOrderRemind' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = '显示服务合同产品服务到期提醒' where languagetype = 'zh' and labelbol = 'ServiceContractsRemind' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Display expiration alerts for service contract products' where languagetype = 'en' and labelbol = 'ServiceContractsRemind' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = '显示收款计划到期提醒' where languagetype = 'zh' and labelbol = 'PaymentPlanRemind' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Display a receivables plan expiration reminders' where languagetype = 'en' and labelbol = 'PaymentPlanRemind' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = '显示付款计划到期提醒' where languagetype = 'zh' and labelbol = 'SendPaymentRemind' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Display payment plan expiry reminders' where languagetype = 'en' and labelbol = 'SendPaymentRemind' and Labeltype = 'fixedstr';
delimiter;

call AddColumn('ld_moduledatamap','lockstate','char','10','no');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UNLOCKHINTSBYCLICK','当前联系人图谱已锁定，请先点击右侧按钮解锁','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='UNLOCKHINTSBYCLICK' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UNLOCKHINTSBYCLICK','The current contact map is locked,Please click the button on the right to unlock it first','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='UNLOCKHINTSBYCLICK' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UNLOCKHINTSBYCLICK','当前联系人图谱已锁定，请先点击右侧按钮解锁','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='UNLOCKHINTSBYCLICK' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UNLOCKHINTSBYCLICK','The current contact map is locked,Please click the button on the right to unlock it first','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='UNLOCKHINTSBYCLICK' and Labeltype='jspop' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UNLOCKHINTS','当前联系人图谱已锁定，请先解锁','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='UNLOCKHINTS' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UNLOCKHINTS','The current contact map is locked,Please unlock it first','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='UNLOCKHINTS' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UNLOCKHINTS','当前联系人图谱已锁定，请先解锁','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='UNLOCKHINTS' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UNLOCKHINTS','The current contact map is locked,Please unlock it first','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='UNLOCKHINTS' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VISIBLED','显示','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='VISIBLED' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','VISIBLED','Visible','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='VISIBLED' and Labeltype='fixedstr' and languagetype='en');
delimiter;

SET @tmp_sequence = (SELECT sequence from ld_systems_deploy WHERE roottype = 1 and id = 75);
UPDATE ld_systems_deploy set sequence = sequence +1 where roottype = 1 and sequence > @tmp_sequence;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 'yes',465,'设置预收单金额和可抵扣金额录入负数时是否允许保存','',@tmp_sequence+1,1,'select',0,'[{"value":"yes","text":"YES"},{"value":"no","text":"NO"},{"sql":""}]' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type = 465);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',465,465,'设置预收单金额和可抵扣金额录入负数时是否允许保存'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_systems_deploy' and tabid = 465 and relateid=465);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',465,465,'Set whether to allow saving when entering negative amounts for advance receipts and deductible amounts'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_systems_deploy' and tabid = 465 and relateid=465);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ActualReceiptsMustGreater0','实际收款金额必须输入大于等于0的数字','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ActualReceiptsMustGreater0' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ActualReceiptsMustGreater0','Actual Receipts must be entered as a number greater than or equal to 0','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ActualReceiptsMustGreater0' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DeductibleAmountMustGreater0','第{Var}行 预收单可抵扣金额必须输入大于等于0的数字','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DeductibleAmountMustGreater0' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DeductibleAmountMustGreater0','The deductible amount of the advance receipt in line {Var} must be entered a number greater than or equal to 0','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DeductibleAmountMustGreater0' and Labeltype='fixedstr' and languagetype='en');
delimiter;

SET @module = 'Users';
SET @tabid = (SELECT tabid from ld_tab where `name` = @module);
SET @tablename = (SELECT main_tablename from ld_tab where `name` = @module);
SET @blockid = (SELECT block from ld_field where tabid = @tabid and columnname = 'last_name');
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
SET @max_sequence = (SELECT MAX(sequence) from ld_field where tabid = @tabid and block = @blockid);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,bigtype,maxrowsshow,approve_demand)
SELECT @tabid,@maxfieldid+1,'latestpushtime','yes',@tablename,2,86,'latestpushtime','最新推进时间',0,1,@max_sequence+1,@blockid ,2,'DT~O',1,0,1,'datetime',0,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='latestpushtime');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='latestpushtime');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'最新推进时间' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Latest push time' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
CALL AddColumn(@tablename,'latestpushtime','datetime','','');
delimiter;


SET @stufftitle = 'TargetAnalysis';
insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule,pc_show,mobile_show)
select 114,@stufftitle,'chart','SalesGoal','yes','yes' from dual
where not exists(select 1 from ld_stuff where stuffid=114 and stufftitle=@stufftitle and stufftype='chart');
delimiter;

SET @labelbol = 'TargetAnalysis';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'目标完成率分析（多仪表盘）','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Target Completion Rate analysis (multi-dashboard)','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

call AddColumn('ld_homestuffsaleskit2board','relatedid','varchar','30','');
call AddColumn('ld_homestuffsaleskit2board','relatedtablename','varchar','30','');
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,stufflabel_zh,stufflabel_en,is_default)
SELECT 114,'TargetAnalysisMonth','fixedstr','本月目标完成情况','Achievement of monthly targets','yes'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='TargetAnalysisMonth');
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,stufflabel_zh,stufflabel_en,is_default)
SELECT 114,'TargetAnalysisYearSchedual','fixedstr','年度目标进度情况','Progress on annual targets','yes'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='TargetAnalysisYearSchedual');
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,stufflabel_zh,stufflabel_en,is_default)
SELECT 114,'TargetAnalysisYear','fixedstr','年度目标完成情况','Achievement of annual targets','yes'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='TargetAnalysisYear');
delimiter;

CREATE TABLE if not EXISTS `ld_homestuffdetail_setting` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `homestuffdetailid` int(11) DEFAULT 0 COMMENT 'ld_homestuffdetail表的id',
    `type` varchar(100) DEFAULT NULL COMMENT '设置的类型',
    `setvalue` varchar(255) DEFAULT '' COMMENT '设置的值',
    PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

SET @homestuffdetailid = (SELECT id from ld_homestuffdetail WHERE stufflabel = 'TargetAnalysisYear');
INSERT INTO ld_homestuffdetail_setting(homestuffdetailid,type,setvalue)
SELECT @homestuffdetailid,'TargetScope','Home'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail_setting WHERE homestuffdetailid=@homestuffdetailid AND type='TargetScope');
INSERT INTO ld_homestuffdetail_setting(homestuffdetailid,type,setvalue)
SELECT @homestuffdetailid,'TargetDate','Year'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail_setting WHERE homestuffdetailid=@homestuffdetailid AND type='TargetDate');
INSERT INTO ld_homestuffdetail_setting(homestuffdetailid,type,setvalue)
SELECT @homestuffdetailid,'TargetDateFrom','HomeEnd'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail_setting WHERE homestuffdetailid=@homestuffdetailid AND type='TargetDateFrom');
INSERT INTO ld_homestuffdetail_setting(homestuffdetailid,type,setvalue)
SELECT @homestuffdetailid,'DoneScope','Home'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail_setting WHERE homestuffdetailid=@homestuffdetailid AND type='DoneScope');
INSERT INTO ld_homestuffdetail_setting(homestuffdetailid,type,setvalue)
SELECT @homestuffdetailid,'DoneDate','Year'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail_setting WHERE homestuffdetailid=@homestuffdetailid AND type='DoneDate');
INSERT INTO ld_homestuffdetail_setting(homestuffdetailid,type,setvalue)
SELECT @homestuffdetailid,'DoneDateFrom','HomeEnd'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail_setting WHERE homestuffdetailid=@homestuffdetailid AND type='DoneDateFrom');
delimiter;

SET @homestuffdetailid = (SELECT id from ld_homestuffdetail WHERE stufflabel = 'TargetAnalysisYearSchedual');
INSERT INTO ld_homestuffdetail_setting(homestuffdetailid,type,setvalue)
SELECT @homestuffdetailid,'TargetScope','Home'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail_setting WHERE homestuffdetailid=@homestuffdetailid AND type='TargetScope');
INSERT INTO ld_homestuffdetail_setting(homestuffdetailid,type,setvalue)
SELECT @homestuffdetailid,'TargetDate','YearProgress'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail_setting WHERE homestuffdetailid=@homestuffdetailid AND type='TargetDate');
INSERT INTO ld_homestuffdetail_setting(homestuffdetailid,type,setvalue)
SELECT @homestuffdetailid,'TargetDateFrom','HomeEnd'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail_setting WHERE homestuffdetailid=@homestuffdetailid AND type='TargetDateFrom');
INSERT INTO ld_homestuffdetail_setting(homestuffdetailid,type,setvalue)
SELECT @homestuffdetailid,'DoneScope','Home'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail_setting WHERE homestuffdetailid=@homestuffdetailid AND type='DoneScope');
INSERT INTO ld_homestuffdetail_setting(homestuffdetailid,type,setvalue)
SELECT @homestuffdetailid,'DoneDate','YearProgress'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail_setting WHERE homestuffdetailid=@homestuffdetailid AND type='DoneDate');
INSERT INTO ld_homestuffdetail_setting(homestuffdetailid,type,setvalue)
SELECT @homestuffdetailid,'DoneDateFrom','HomeEnd'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail_setting WHERE homestuffdetailid=@homestuffdetailid AND type='DoneDateFrom');
delimiter;

SET @homestuffdetailid = (SELECT id from ld_homestuffdetail WHERE stufflabel = 'TargetAnalysisMonth');
INSERT INTO ld_homestuffdetail_setting(homestuffdetailid,type,setvalue)
SELECT @homestuffdetailid,'TargetScope','Home'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail_setting WHERE homestuffdetailid=@homestuffdetailid AND type='TargetScope');
INSERT INTO ld_homestuffdetail_setting(homestuffdetailid,type,setvalue)
SELECT @homestuffdetailid,'TargetDate','Month'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail_setting WHERE homestuffdetailid=@homestuffdetailid AND type='TargetDate');
INSERT INTO ld_homestuffdetail_setting(homestuffdetailid,type,setvalue)
SELECT @homestuffdetailid,'TargetDateFrom','HomeEnd'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail_setting WHERE homestuffdetailid=@homestuffdetailid AND type='TargetDateFrom');
INSERT INTO ld_homestuffdetail_setting(homestuffdetailid,type,setvalue)
SELECT @homestuffdetailid,'DoneScope','Home'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail_setting WHERE homestuffdetailid=@homestuffdetailid AND type='DoneScope');
INSERT INTO ld_homestuffdetail_setting(homestuffdetailid,type,setvalue)
SELECT @homestuffdetailid,'DoneDate','Month'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail_setting WHERE homestuffdetailid=@homestuffdetailid AND type='DoneDate');
INSERT INTO ld_homestuffdetail_setting(homestuffdetailid,type,setvalue)
SELECT @homestuffdetailid,'DoneDateFrom','HomeEnd'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail_setting WHERE homestuffdetailid=@homestuffdetailid AND type='DoneDateFrom');
delimiter;

SET @labelbol = 'INCOMPLETEVALUE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'未完成值','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Incomplete Value','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'BYUSER';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'按用户','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'By User','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'EditTargetAnalysis';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'目标完成率分析定制','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Customized The Gauge List of Target achievement rate','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SearchGaugeName';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'搜索仪表盘名称','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Search for the gauge name','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DefaultTargetAnalysis';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'预设仪表盘','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Search for the gauge name','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DefaultTargetAnalysis';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'预设仪表盘','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Default gauge','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CustomTargetAnalysis';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'自定义仪表盘','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Customized gauge','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NewCustomTargetAnalysis';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'新增自定义仪表盘','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Add customized gauge','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'TargetAnalysisTip';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'拖动仪表盘移入画板以添加仪表盘','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Drag the gauge into the drawing board to add it','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'TargetAnalysisTip2';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'双击添加仪表盘','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Double-click to add the gauge','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CustomGauge';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'自定义仪表盘',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Customized gauge',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'GaugeRowNum';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'每行仪表盘个数',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Num of gauge row',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'RowHeight';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'每行高度',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Height of each row',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'LAYOUTSETTING';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'布局设置',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Layout setting',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'GaugeSet';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'仪表盘设置',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Gauge setting',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'ClickGaugeToSet';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'点击仪表盘进行设置',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Click on the gauge to set up',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'ClickGaugeToSet';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'点击仪表盘进行设置',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Click on the gauge to set up',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;


SET @labelbol = 'TargetSet';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'目标值设置',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Settings of target',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'TargetSetTip';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请选择目标值的设置',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Select the settings of the target',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'DoneSet';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'完成值设置',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Settings of target completion value',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'DoneSetTip';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请选择完成值的设置',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Select the settings of target completion value',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'CurMonthValue';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'本月时间取值',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Time of this month',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'ByHomeDateStart';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'按首页起始时间',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'By home start time',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'ByHomeDateEnd';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'按首页截止时间',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'By home end time',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'CancelTargetAnalysis';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'该设置没有保存，退出将丢失未保存的信息，确定要退出吗？',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The settings has not been saved. Exiting will lose any unsaved information. Are you sure you want to exit?',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'TopXAxis';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'上X轴',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Top X Axis',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'BottomXAxis';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'下X轴',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Bottom X Axis',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PRESSENTERTOADD','请输入并按回车添加','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PRESSENTERTOADD' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PRESSENTERTOADD','Please enter and press ’Enter‘ to add','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PRESSENTERTOADD' and Labeltype='fixedstr' and languagetype='en');
delimiter;
-- 2024-01-05

DROP PROCEDURE IF EXISTS `ldcrm_reset_producttoolfield_20240108`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_producttoolfield_20240108`(
)
BEGIN

	DECLARE tmp_tabid INT(19) DEFAULT 0;
	DECLARE tmp_producttoolfieldid INT(19) DEFAULT 0;
	DECLARE tmp_columnname VARCHAR(100) DEFAULT '';
	DECLARE tmp_tablename VARCHAR(100) DEFAULT '';
	
	DECLARE MYCUSOR CURSOR FOR 
		SELECT  
			tabid,
			producttoolfieldid,
			columnname,
			tablename
		FROM ld_producttoolfield 
		WHERE presence=1 
			AND columnname In ('sf2193','sf2402','sf2611','sf2856','imagename')
			AND fieldlabel IN ('1','2','测试11','测试','123213','测定11');

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_producttoolfieldid = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_tabid,tmp_producttoolfieldid,tmp_columnname,tmp_tablename;
	WHILE(tmp_producttoolfieldid IS NOT NULL) DO
		DELETE FROM ld_tranlabel WHERE trantable='ld_producttoolfield' AND tabid=tmp_tabid AND Relateid=tmp_producttoolfieldid;
		DELETE FROM ld_producttoolfield WHERE tabid=tmp_tabid AND producttoolfieldid=tmp_producttoolfieldid;

		IF tmp_tablename NOT IN ('ld_products','ld_productcf') THEN
			CALL DelColumn(tmp_tablename,tmp_columnname);
		END IF;

		FETCH MYCUSOR INTO tmp_tabid,tmp_producttoolfieldid,tmp_columnname,tmp_tablename;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

CALL ldcrm_reset_producttoolfield_20240108();
DROP PROCEDURE IF EXISTS `ldcrm_reset_producttoolfield_20240108`;

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

UPDATE ld_version SET old_version='V8.6.2.1',current_version='V8.6.2.1',remark='V8.6.2.1-20240105',wx_version='V8.6.2.0';
delimiter;