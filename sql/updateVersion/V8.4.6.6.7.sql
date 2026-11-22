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

update ld_field set typeofdata='N~O~20,2' where columnname='projecttaskhours' and tablename='ld_projecttask' and typeofdata='V~O';
update ld_field set typeofdata='N~O~20,2' where columnname='costbudget' and tablename='ld_projecttask' and typeofdata='V~O';
update ld_field set typeofdata='N~O~20,2' where columnname='timebudget' and tablename='ld_projecttask' and typeofdata='V~O';
update ld_field set typeofdata='N~O~20,2' where columnname='hascost' and tablename='ld_projecttask' and typeofdata='V~O';
delimiter;

ALTER TABLE ld_projecttask MODIFY COLUMN projecttaskhours decimal(25,2) NOT NULL DEFAULT '0.00';
delimiter;


update ld_field set typeofdata='N~O~25,2' where columnname='targetbudget' and tablename='ld_project' and typeofdata='V~O';
update ld_field set typeofdata='N~O~25,2' where columnname='totalcost' and tablename='ld_projectprogress' and typeofdata='V~O';
update ld_field set typeofdata='N~O~25,2' where columnname='hascost' and tablename='ld_project' and typeofdata='V~O';
update ld_field set typeofdata='N~O~25,2' where columnname='cf_4942' and tablename='ld_projectprogresscf' and typeofdata='V~O';
delimiter;


ALTER TABLE ld_project MODIFY COLUMN targetbudget decimal(25,2) NOT NULL DEFAULT '0.00';
delimiter;
-- 2022-07-01


update ld_desk set fieldlabel='Agree' where labelbol='Agree' and languagetype='en' and Labeltype='fixedstr';
delimiter;

CALl AddColumn('ld_customtable_condition','groupid','int','11','1');
CALl AddColumn('ld_customtable_condition','columncondition','varchar','255','and');

create table if not exists `ld_customtable_condition_grouping` (
	`report_id` int(11) NOT NULL,
	`groupid` int(11) DEFAULT NULL,
	`group_condition` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

update ld_desk set fieldlabel='新条件' where labelbol='NEW2' and Labeltype='jspop' and languagetype='zh';
update ld_desk set fieldlabel='New Conditions' where labelbol='NEW2' and Labeltype='jspop' and languagetype='en';
delimiter;

SET @labelbol = 'CONTROLEFFECTIVECONDITIONS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'可通过“设置控制生效条件”设置满足设定条件才执行该控制','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'you can set control effective conditions to perform the control when the conditions are met','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'AUTOMATICALLY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'设置源单分录明细范围','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Setting the source entry details range','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

update ld_producttoolfield set bigtype='selectsource' where uitype in (200,201);
delimiter;

CALL AddColumn('ld_producttoolfield','parentbigtype','varchar','50','');
delimiter;
CALL AddColumn('ld_tabdetailfield','parentbigtype','varchar','50','');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','referencefieldtypedifferent','引用字段类型不一致','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='referencefieldtypedifferent' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','referencefieldtypedifferent',"Inconsistent reference field types",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='referencefieldtypedifferent' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','referencefieldmoduledifferent','引用字段关联模块不一致','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='referencefieldmoduledifferent' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','referencefieldmoduledifferent',"Reference field association module is inconsistent",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='referencefieldmoduledifferent' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UNINSTALL','卸载','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='UNINSTALL' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UNINSTALL','uninstall','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='UNINSTALL' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','UninstallSelfBuiltTip','卸载后自建应用将无法使用，确定卸载吗？','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='UninstallSelfBuiltTip' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','UninstallSelfBuiltTip','The self-built application cannot be used after uninstallation. Are you sure to uninstall it?','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='UninstallSelfBuiltTip' and Labeltype='jspop');
delimiter;

SET @labelbol = 'PUSHOPERAATIONSTYLE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'推进操作样式','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Push operation style','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NEWDIALOG';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'在推进弹出界面展示和操作','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'New dialog','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'BELOWPROPULSIONLOG';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'在推进日志下方展示和操作','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Below propulsion log','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PUSHLOGSTYLE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'推进日志样式','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Push log style','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'UNDERADVANCENODE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'在推进节点下方点击显示','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Click to display below node','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'TILEBELOWNODE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'在推进节点下方平铺显示','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Tile below node','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

call AddColumn('ld_settings_advance','operatestyle','varchar','20','');
delimiter;
call AddColumn('ld_settings_advance','logshowstyle','varchar','20','');
delimiter;

UPDATE ld_settings_advance SET operatestyle = 'underadvance' where (operatestyle = '' or operatestyle is NULL);
UPDATE ld_settings_advance SET logshowstyle = 'inpopup' where (logshowstyle = '' or logshowstyle is NULL);
delimiter;

update ld_producttoolfield set bigtype='selectsource' where uitype =202;
delimiter;

SET @Parent_id = (select Parent_id from ld_usereport where name='SIGNINSTATISTICS');
SET @sequence = (select sequence from ld_usereport where name='SIGNINSTATISTICS');
SET @maxsequence = (SELECT max(sequence) FROM ld_usereport WHERE Parent_id = @Parent_id);
update ld_usereport SET sequence = sequence + 1 WHERE sequence > @sequence AND Parent_id = @Parent_id AND @maxsequence < 6;
insert into ld_usereport(name, reportlabel, tabids, basicfilter, advfilter, Setcolumns,Parent_id, sequence, reporttype, pagewidthpercent, presence)
select 'Sign_in_track','签到轨迹表',0,1,0,1,@Parent_id,@sequence+1,52,100,0 from dual
where not exists(select 1 from ld_usereport where name='Sign_in_track');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Sign_in_track','签到轨迹表','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Sign_in_track' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Sign_in_track','Sign In Track','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Sign_in_track' and labeltype='fixedstr');

SET @usereportid = (select usereportid from ld_usereport where name="Sign_in_track");
insert into ld_usereportbasic(Usereportid,`columns`,Defaultvalue,Sequence)
select @usereportid,'ld_singin:createdtime:signedtime:Singin_CreatedTime:D','thisstartmonth~thisendmonth',1 from DUAL
where not exists(select 1 from ld_usereportbasic where Usereportid = @usereportid and `columns` = 'ld_singin:createdtime:signedtime:Singin_CreatedTime:D');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SINGINADDRESSJS','签到地址','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SINGINADDRESSJS' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SINGINADDRESSJS',"Sign in place",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SINGINADDRESSJS' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SIGNTIMEJS','签到时间','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SIGNTIMEJS' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SIGNTIMEJS',"Sign Time",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SIGNTIMEJS' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VISITORS','拜访对象','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='VISITORS' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','VISITORS',"Visitors",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='VISITORS' and labeltype='jspop');
delimiter;

UPDATE ld_desk SET fieldlabel = '签到分布表' where labelbol = 'Sign_in_track' AND languagetype = 'zh' AND Labeltype = 'fixedstr';
delimiter;
UPDATE ld_usereport SET reportlabel = '签到分布表' where `name` = 'Sign_in_track';
delimiter;

SET @labelbol = 'DatabasefieldID';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'数据库字段id','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Database field ID','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;
-- 2022-07-06

UPDATE ld_desk SET fieldlabel='设置源单分录明细范围' WHERE labelbol='AUTOMATICALLY' AND Labeltype='fixedstr' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='Setting the source entry details range' WHERE labelbol='AUTOMATICALLY' AND Labeltype='fixedstr' AND languagetype='en';


SET @labelbol = 'NEXTSTAGE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'下一阶段','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Next stage','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel = '请选择下一阶段' where labelbol = 'PLEASECHOOSENEXTSTAGE' and languagetype = 'zh' AND Labeltype = 'jspop';
delimiter;

UPDATE ld_desk SET fieldlabel = '设置各阶段间的先后流转关系，请在需要流转的阶段间的复选框内打勾。' where labelbol = 'SETADVANCERELATION' and languagetype = 'zh' AND Labeltype = 'fixedstr';
delimiter;

alter table ld_organizationdetails modify column brief_title varchar(255);
delimiter;

DROP PROCEDURE IF EXISTS `add_shouye_jianbao`;
delimiter ||
CREATE  PROCEDURE `add_shouye_jianbao`(
	tmp_module VARCHAR(100),
	tmp_label  VARCHAR(100),
	tmp_zhname VARCHAR(100),
	tmp_enname VARCHAR(100),
	tmp_formulatype VARCHAR(100),
	tmp_formulacolumn VARCHAR(100),
	tmp_querydatefield VARCHAR(100)
)
BEGIN

	SET @jianbao_module=tmp_module;
	SET @jianbao_label=tmp_label;
	SET @jianbao_zhname=tmp_zhname;
	SET @jianbao_enname=tmp_zhname;
	SET @jianbao_formulatype=tmp_formulatype;
	SET @jianbao_formulacolumn=tmp_formulacolumn;	
	SET @querydatefield=tmp_querydatefield;

	IF tmp_formulatype='count' THEN 
		SET @jianbao_formulacolumn=(
			SELECT 
				CONCAT(b.tablename,'.',a.entityidfield)
			FROM ld_entityname a
			INNER JOIN ld_field b ON b.tabid=a.tabid AND b.columnname='smownerid'
			WHERE a.modulename=@jianbao_module
			LIMIT 1
		);

		SET @ico='crm_SalesOrder.png';
	ELSE
		SET @jianbao_formulacolumn=(
			SELECT 
				CONCAT(tablename,'.',@jianbao_formulacolumn) 
			FROM ld_field 
			WHERE columnname='smownerid' 
				AND tabid=(SELECT tabid FROM ld_tab WHERE name=tmp_module) 
			LIMIT 1
		);

		SET @ico='item-ico-salesorder';
	END IF;
	
	IF @jianbao_module IN ('Accounts','Leads') THEN
		SET @page_to=CONCAT('index.php?pageto_module=',@jianbao_module,'&pageto_action=index&pagepublicaccounttype=ALLACCOUNT');
	ELSE
		SET @page_to=CONCAT('index.php?pageto_module=',@jianbao_module,'&pageto_action=index');
	END IF;

	SET @seq=IFNULL((SELECT MAX(sequence) FROM ld_homestuffdetail),0)+1;

	IF NOT EXISTS (SELECT 1 FROM ld_homestuffdetail WHERE stufflabel=@jianbao_label) THEN
		INSERT INTO `ld_homestuffdetail` (`stuffid`, `stufflabel`, `stufflabeltype`, `compute_columns`, `compute_type`, `pageurl`, `sequence`, `cssname`, `presence`, `icon`)
		SELECT '35',@jianbao_label,'fixedstr',@jianbao_formulacolumn,@jianbao_formulatype,@page_to,@seq,'item-ico-salesorder','yes',@ico;

		DELETE FROM ld_desk WHERE labelbol=@jianbao_label AND Labeltype='fixedstr';
		INSERT INTO `ld_desk` (`languagetype`, `labelbol`, `fieldlabel`, `Labeltype`) 
		SELECT 'zh',@jianbao_label,@jianbao_zhname, 'fixedstr';

		INSERT INTO `ld_desk` (`languagetype`, `labelbol`, `fieldlabel`, `Labeltype`) 
		SELECT 'en',@jianbao_label,@jianbao_enname, 'fixedstr';


		SET @homestuffdetailid=(SELECT id FROM ld_homestuffdetail WHERE stufflabel=@jianbao_label LIMIT 1);

		SET @date_column=(
			SELECT
				CONCAT(a.tablename,':',a.columnname,':',a.columnname,':',c.name,'_',b.fieldlabel,':',LEFT(a.typeofdata,IF(LOCATE('~',a.typeofdata)-1>0,LOCATE('~',a.typeofdata)-1,1)))
			FROM ld_field a
			INNER JOIN ld_tranlabel b ON b.trantable='ld_field' AND b.Relateid=a.fieldid AND b.languagetype='zh'
			LEFT JOIN ld_tab c ON c.tabid=a.tabid
			WHERE c.name=@jianbao_module
				AND a.columnname=@querydatefield
			LIMIT 1	
		);

		SET @approve_column=(
			SELECT
				CONCAT(a.tablename,':',a.columnname,':',a.columnname,':',c.name,'_',b.fieldlabel,':',LEFT(a.typeofdata,IF(LOCATE('~',a.typeofdata)-1>0,LOCATE('~',a.typeofdata)-1,1)))
			FROM ld_field a
			INNER JOIN ld_tranlabel b ON b.trantable='ld_field' AND b.Relateid=a.fieldid AND b.languagetype='zh'
			LEFT JOIN ld_tab c ON c.tabid=a.tabid
			WHERE c.name=@jianbao_module
				AND a.columnname='approvestatus'
			LIMIT 1	
		);


		INSERT INTO `ld_homestuffdetailcondition` (`homestuffdetailid`, `groupid`, `columns`, `value`, `comparator`)
		SELECT @homestuffdetailid, '1', @date_column, '', '';

		INSERT INTO `ld_homestuffdetailcondition` (`homestuffdetailid`, `groupid`, `columns`, `value`, `comparator`)
		SELECT @homestuffdetailid, '1', @approve_column, '', '';


		SELECT CONCAT('增加成功') AS 操作说明;
	ELSE
		SELECT  CONCAT('简报已存在，请修改变量 @jianbao_label') AS 操作说明;
	END IF;

end ||
delimiter;

SET @labelbol = 'SetTheSourceEntryDetailsRange';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'设置源单分录明细范围','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Set the source entry details range','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

UPDATE ld_field SET presence=2 WHERE columnname='publicaccount' AND presence=1 AND tablename='ld_account' AND EXISTS (SELECT 1 FROM ld_account_public WHERE `status`='yes');
UPDATE ld_field SET presence=2 WHERE columnname='publicaccount' AND presence=1 AND tablename='ld_leads' AND EXISTS (SELECT 1 FROM ld_account_public WHERE `status`='yes') ;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ExpenseBudget' LIMIT 1);
SET @parenttabid=(SELECT parenttabid FROM ld_parenttabrel WHERE tabid=@tabid LIMIT 1);
SET @seq=IFNULL((SELECT MAX(sequence) FROM ld_parenttabrel WHERE parenttabid=@parenttabid),0);

SET @tabid1=(SELECT tabid FROM ld_tab WHERE `name`='BudgetChange' LIMIT 1);
INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
SELECT @parenttabid,@tabid1,@seq+1,'ld_tab' FROM DUAL
WHERE @parenttabid>0 AND NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE tabid=@tabid1);
delimiter;
-- 2022-07-06

DROP PROCEDURE IF EXISTS `account_singlerecycle_highsea_rule_beforeremind`;
delimiter ||
CREATE PROCEDURE `account_singlerecycle_highsea_rule_beforeremind`(IN tmp_pool_id INT(11))
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

	declare cur1 CURSOR FOR select  tabname,ld_account_set_rule.columnname,ld_field.tablename ,ld_account_set_rule.iscycle, `condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and  (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' and pool_id = tmp_pool_id;
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
 select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' and pool_id = tmp_pool_id;

    select beforereminddays into @var_beforereminddays  from ld_account_public_pool where  id = tmp_pool_id;


 if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then
		leave label_a ;
	end if;
  select userid_after_release into @allotaccount from ld_account_public_pool where id = tmp_pool_id;
	select recycleselect into @recycleselect from ld_account_public_pool where id = tmp_pool_id;
	

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

					set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
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
					set @tmpsql=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)<=",var_days);
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

			 set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;

			set @TMPSQL_ONE=concat( ' select "complete",  group_concat(concat (ld_account.accountname,',@TMP_TMPTable,') separator "<br>" )  as accouontnames ,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
			end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id);
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
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

			  set @TMPSQL_ONE=concat( ' select "complete",  GROUP_CONCAT(concat(ld_account.accountname,"(",lingdangtmp.fieldlabel,")") separator "<br>")as accountnames,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;

				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0  and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id,'  group by ld_account.smownerid    ');
		end if;

		delete from ld_publicaccount_remindtableview ;
        set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

        call crm_publicaccount_beforereminds();
	end if;
end ||
delimiter;

DROP TRIGGER IF EXISTS `ldcrm_remind_smowner`;
delimiter ||
CREATE TRIGGER `ldcrm_remind_smowner` AFTER INSERT ON `ld_modcomments` FOR EACH ROW BEGIN

  SELECT setype INTO @reltab FROM ld_crmentity WHERE crmid=NEW.related_to;

  IF NEW.related_to>0 THEN
    SELECT
      b.fieldlabel INTO @content
    FROM ld_tab a
    LEFT JOIN ld_tranlabel b ON a.tabid=b.Relateid AND b.trantable='ld_tab' AND b.languagetype='zh'
    WHERE a.`name`=@reltab LIMIT 1;
	
    SET @content=(
			SELECT 
				CONCAT(
				(CASE WHEN IFNULL(real_name,'')<>'' AND user_name LIKE 'wobOQUDw%' THEN real_name ELSE IFNULL(last_name,'') END),
				'评论了您的',
				@content,
				'，评论内容如下：',
				IFNULL(NEW.commentcontent,'')
			)
			FROM ld_users 
			WHERE id=NEW.smownerid LIMIT 1
		);

    SET @smownerid=0;
    SET @servicecasher=0;
    IF @reltab='Accounts' THEN
      SELECT smownerid INTO @smownerid FROM ld_account WHERE accountid=NEW.related_to limit 1;
      SELECT servicecasher INTO @servicecasher FROM ld_account WHERE accountid=NEW.related_to limit 1;
    ELSEIF @reltab='Contacts' THEN
      SELECT smownerid INTO @smownerid FROM ld_contactdetails WHERE contactid=NEW.related_to limit 1;
    ELSEIF @reltab='ContactRecords' THEN
      SELECT smownerid INTO @smownerid FROM ld_contactrecords WHERE contactrecordid=NEW.related_to limit 1;
    ELSEIF @reltab='Potentials' THEN
      SELECT smownerid INTO @smownerid FROM ld_potential WHERE potentialid=NEW.related_to limit 1;
    ELSEIF @reltab='Quotes' THEN
      SELECT smownerid INTO @smownerid FROM ld_quotes WHERE quoteid=NEW.related_to limit 1;
    ELSEIF @reltab='SalesOrder' THEN
      SELECT smownerid INTO @smownerid FROM ld_salesorder WHERE salesorderid=NEW.related_to limit 1;
    ELSEIF @reltab='SalesBack' THEN
      SELECT smownerid INTO @smownerid FROM ld_salesback WHERE salesbackid=NEW.related_to limit 1;

    ELSEIF @reltab='ServiceContracts' THEN
      SELECT smownerid INTO @smownerid FROM ld_servicecontracts WHERE servicecontractsid=NEW.related_to limit 1;
    ELSEIF @reltab='ServiceCharge' THEN
      SELECT servicecasher INTO @smownerid FROM ld_account WHERE accountid=NEW.related_to limit 1;
    ELSEIF @reltab='HelpDesk' THEN
      SELECT smownerid INTO @smownerid FROM ld_troubletickets WHERE ticketid=NEW.related_to limit 1;
    ELSEIF @reltab='ServiceReturn' THEN
      SELECT smownerid INTO @smownerid FROM ld_servicereturn WHERE servicereturnid=NEW.related_to limit 1;

    ELSEIF @reltab='Project' THEN
      SELECT smownerid INTO @smownerid FROM ld_project WHERE projectid=NEW.related_to limit 1;
    ELSEIF @reltab='ProjectTask' THEN
      SELECT smownerid INTO @smownerid FROM ld_projecttask WHERE projecttaskid=NEW.related_to limit 1;
    ELSEIF @reltab='ProjectMilestone' THEN
      SELECT smownerid INTO @smownerid FROM ld_projectmilestone WHERE projectmilestoneid=NEW.related_to limit 1;
    ELSEIF @reltab='TimeSheet' THEN
      SELECT smownerid INTO @smownerid FROM ld_timesheet WHERE timesheet_id=NEW.related_to limit 1;
    ELSEIF @reltab='ProjectProgress' THEN
      SELECT smownerid INTO @smownerid FROM ld_projectprogress WHERE projectprogressid=NEW.related_to limit 1;
    ELSEIF @reltab='Rate' THEN
      SELECT smownerid INTO @smownerid FROM ld_rate WHERE rate_id=NEW.related_to limit 1;

    ELSEIF @reltab='Invoice' THEN
      SELECT smownerid INTO @smownerid FROM ld_invoice WHERE invoiceid=NEW.related_to limit 1;
    ELSEIF @reltab='PurchaseInvoice' THEN
      SELECT smownerid INTO @smownerid FROM ld_purchaseinvoice WHERE purchaseinvoiceid=NEW.related_to limit 1;
    ELSEIF @reltab='CashBill' THEN
      SELECT smownerid INTO @smownerid FROM ld_cashbill WHERE cashbillid=NEW.related_to limit 1;
    ELSEIF @reltab='SendCashBill' THEN
      SELECT smownerid INTO @smownerid FROM ld_sendcashbill WHERE sendcashbillid=NEW.related_to limit 1;
    ELSEIF @reltab='CashBack' THEN
      SELECT smownerid INTO @smownerid FROM ld_cashback WHERE cashbackid=NEW.related_to limit 1;
    ELSEIF @reltab='PurchaseCashBack' THEN
      SELECT smownerid INTO @smownerid FROM ld_purchasecashback WHERE purchasecashbackid=NEW.related_to limit 1;
    ELSEIF @reltab='PaymentPlan' THEN
      SELECT smownerid INTO @smownerid FROM ld_paymentplan WHERE paymentplanid=NEW.related_to limit 1;
    ELSEIF @reltab='SendPayment' THEN
      SELECT smownerid INTO @smownerid FROM ld_sendpayment WHERE sendpaymentid=NEW.related_to limit 1;
    ELSEIF @reltab='PutCash' THEN
      SELECT smownerid INTO @smownerid FROM ld_putcash WHERE putcashid=NEW.related_to limit 1;
    ELSEIF @reltab='CashDeposit' THEN
      SELECT smownerid INTO @smownerid FROM ld_cashdeposit WHERE cashdepositid=NEW.related_to limit 1;
    ELSEIF @reltab='BankAccountSet' THEN
      SELECT smcreatorid INTO @smownerid FROM ld_bankaccountset WHERE Bankaccountsetid=NEW.related_to limit 1;

    ELSEIF @reltab='OutboundOrder' THEN
      SELECT smownerid INTO @smownerid FROM ld_outboundorder WHERE out_id=NEW.related_to limit 1;
    ELSEIF @reltab='Stock' THEN
      SELECT smownerid INTO @smownerid FROM ld_stock WHERE stock_id=NEW.related_to limit 1;
    ELSEIF @reltab='WareHouseTransfer' THEN
      SELECT smownerid INTO @smownerid FROM ld_warehousetransfer WHERE warehousetransferid=NEW.related_to limit 1;
    ELSEIF @reltab='Checks' THEN
      SELECT smownerid INTO @smownerid FROM ld_checks WHERE id=NEW.related_to limit 1;

    ELSEIF @reltab='Vendors' THEN
      SELECT smownerid INTO @smownerid FROM ld_vendor WHERE vendorid=NEW.related_to limit 1;
    ELSEIF @reltab='VendorContact' THEN
      SELECT smownerid INTO @smownerid FROM ld_vendorcontacts WHERE vendorcontactsid=NEW.related_to limit 1;
    ELSEIF @reltab='VendorContactRecords' THEN
      SELECT smownerid INTO @smownerid FROM ld_vendorcontactrecords WHERE contactRecordsid=NEW.related_to limit 1;
    ELSEIF @reltab='PurchaseOrder' THEN
      SELECT smownerid INTO @smownerid FROM ld_purchaseorder WHERE purchaseorderid=NEW.related_to limit 1;
    ELSEIF @reltab='PurchaseBack' THEN
      SELECT smownerid INTO @smownerid FROM ld_purchaseback WHERE purchasebackid=NEW.related_to limit 1;

    ELSEIF @reltab='Campaigns' THEN
      SELECT smownerid INTO @smownerid FROM ld_campaign WHERE campaignid=NEW.related_to limit 1;

    ELSEIF @reltab='NormalApprove' THEN
      SELECT smownerid INTO @smownerid FROM ld_normalapprove WHERE normalapproveid=NEW.related_to limit 1;
    ELSEIF @reltab='AddJobBill' THEN
      SELECT smownerid INTO @smownerid FROM ld_addjobbill WHERE addjobbillid=NEW.related_to limit 1;
    ELSEIF @reltab='MinusJobBill' THEN
      SELECT smownerid INTO @smownerid FROM ld_minusjobbill WHERE minusjobbillid=NEW.related_to limit 1;
    ELSEIF @reltab='BusinessApply' THEN
      SELECT smownerid INTO @smownerid FROM ld_businessapply WHERE businessapplyid=NEW.related_to limit 1;
    ELSEIF @reltab='LoanApply' THEN
      SELECT smownerid INTO @smownerid FROM ld_loanapply WHERE loanapplyid=NEW.related_to limit 1;
    ELSEIF @reltab='CardApply' THEN
      SELECT smownerid INTO @smownerid FROM ld_cardapply WHERE cardapplyid=NEW.related_to limit 1;
    ELSEIF @reltab='Commission' THEN
      SELECT smownerid INTO @smownerid FROM ld_commission WHERE commission_id=NEW.related_to limit 1;
    ELSEIF @reltab='Expense' THEN
      SELECT smownerid INTO @smownerid FROM ld_expense WHERE expenseid=NEW.related_to limit 1;

    ELSEIF @reltab='Products' THEN
      SELECT smownerid INTO @smownerid FROM ld_products WHERE productid=NEW.related_to limit 1;
    ELSEIF @reltab='PriceBooks' THEN
      SELECT smownerid INTO @smownerid FROM ld_pricebook WHERE pricebookid=NEW.related_to limit 1;
    ELSEIF @reltab='Documents' THEN
      SELECT smownerid INTO @smownerid FROM ld_notes WHERE notesid=NEW.related_to limit 1;
    ELSEIF @reltab='Faq' THEN
      SELECT smownerid INTO @smownerid FROM ld_faq WHERE id=NEW.related_to limit 1;
    ELSEIF @reltab='Attachment' THEN
      SELECT smownerid INTO @smownerid FROM ld_attachmentsforbills WHERE attachmentsid=NEW.related_to limit 1;
    END IF;

    IF @smownerid>0  AND @smownerid<>NEW.smownerid THEN
      CALL ldcrm_add_reminder_havetype(@content,@smownerid,@reltab,NEW.related_to,'MODULECOMMENTRemind');
    END IF;
    select presence into @presence from ld_tab where name='servicecharge';

    IF @servicecasher>0 AND @smownerid<>@servicecasher AND (@presence=0 or @presence=2) AND @servicecasher<>NEW.smownerid THEN
      CALL ldcrm_add_reminder_havetype(@content,@servicecasher,'ServiceCharge',NEW.related_to,'MODULECOMMENTRemind');
    END IF;
  END IF;

end ||
delimiter;
-- 2022-07-08

ALTER TABLE ld_worksheet modify column description Text;
delimiter;

set @reportid = (SELECT Usereportid FROM ld_usereport where name ='SalesOrderTrack');
select sequence into @sequence from ld_usereportcolumns where `columns`='ld_salesorder:total:hdnGrandTotal:SalesOrder_Total:N'  and Usereportid=@reportid;
UPDATE ld_usereportcolumns set sequence =sequence+1 where sequence>=@sequence and Usereportid=@reportid;
INSERT INTO  ld_usereportcolumns ( `Usereportid`, `columns`, `Sequence`, `columnshow`, `realcolumns`, `realencolumns`, `tabname`, `is_advanced`)
SELECT  @reportid,'ld_salesorder:totalquantity:totalquantity:SalesOrder_quantity:N',@sequence , 1,'ld_salesorder:totalquantity:totalquantity:SalesOrder_合同订单数量合计:N', 'ld_salesorder:totalquantity:totalquantity:SalesOrder_quantity:N', NULL, 0 FROM DUAL
WHERE not  EXISTS (SELECT 1 FROM ld_usereportcolumns WHERE Usereportid=@reportid and columns ='ld_salesorder:totalquantity:totalquantity:SalesOrder_quantity:N');
delimiter;

set @reportid = (SELECT Usereportid FROM ld_usereport where name ='SalesOrderTrack');
select sequence into @sequence from ld_usereportcolumns where `columns`='ld_salesorder:TotalCost:成本合计:OftenUseReport_TotalCost:N'  and Usereportid=@reportid;
UPDATE ld_usereportcolumns set sequence =sequence+1 where sequence>=@sequence and Usereportid=@reportid;
INSERT INTO  ld_usereportcolumns ( `Usereportid`, `columns`, `Sequence`, `columnshow`, `realcolumns`, `realencolumns`, `tabname`, `is_advanced`)
SELECT  @reportid,'ld_salesorder:approvestatus:approvestatus:SalesOrder_approvestatus:V',@sequence , 1,'ld_salesorder:approvestatus:approvestatus:SalesOrder_审批状态:V', 'ld_salesorder:approvestatus:approvestatus:SalesOrder_approvestatus:V', NULL, 0 FROM DUAL
WHERE not  EXISTS (SELECT 1 FROM ld_usereportcolumns WHERE Usereportid=@reportid and columns ='ld_salesorder:approvestatus:approvestatus:SalesOrder_approvestatus:V');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_approvereminds_remindtitle_add`;
delimiter ||
CREATE  PROCEDURE `ldcrm_approvereminds_remindtitle_add`(
)
BEGIN
	declare var_id int(100);
	DECLARE var_type varchar(100);
	DECLARE var_reminduser varchar(100);
	DECLARE var_remindmethod varchar(100);
	DECLARE var_title varchar(100);
	DECLARE var_tabid int(19);
	declare done  int  default 0;

   declare cur1 CURSOR FOR select ld_approvereminds.id as tmp_id,ld_approvereminds.type,ld_approvereminds.reminduser,ld_approvereminds.remindmethod,ld_approvereminds.remindtitle as tmp_title,tmp_table.tabid as tmp_tabid from ld_approvereminds LEFT JOIN (SELECT ld_approvestep.id AS stepid,ld_approve.tabid AS tabid from ld_approvestep LEFT JOIN ld_approve ON ld_approve.id=ld_approvestep.approveid ) AS tmp_table ON tmp_table.stepid = ld_approvereminds.stepid;
		declare continue handler  for not   found  SET done =1;
	OPEN cur1;

	 Fetch cur1 into var_id,var_type,var_reminduser,var_remindmethod, var_title,var_tabid;
	 loop1: while  done<>1 DO
		if  var_remindmethod in ('dialog','weiin') then
			set @modulename = (select fieldlabel from ld_tranlabel where tabid = var_tabid and languagetype = 'zh' and trantable = 'ld_tab');
			set @remindtitle='';
			if var_type=0 and var_reminduser='approver' THEN
				select  concat('【',@modulename,'】审批提醒') into @remindtitle from ld_approvereminds where ld_approvereminds.id=var_id;
			 update ld_approvereminds set remindtitle = concat('【{modulelabel}】审批提醒') where ld_approvereminds.id=var_id and (remindtitle is null or remindtitle='' or remindtitle=@remindtitle);
			elseif var_type=0 and var_reminduser='selectuser'  THEN
				select  remindtitle = concat('【',@modulename,'】审批抄送提醒') into @remindtitle from ld_approvereminds where ld_approvereminds.id=var_id;
				update ld_approvereminds set remindtitle = concat('【{modulelabel}】审批抄送提醒') where ld_approvereminds.id=var_id and (remindtitle is null or remindtitle='' or remindtitle=@remindtitle);
			elseif var_type=1 and var_reminduser='smowner'  THEN
				select  remindtitle = concat('【',@modulename,'】审批结果通知') into @remindtitle from ld_approvereminds where ld_approvereminds.id=var_id;
				update ld_approvereminds set remindtitle = concat('【{modulelabel}】审批结果通知') where ld_approvereminds.id=var_id and (remindtitle is null or remindtitle='' or remindtitle=@remindtitle);
			elseif var_type=1 and var_reminduser in ('smcreator','selectuser')  THEN
				select  remindtitle = concat('【',@modulename,'】审批结果提醒') into @remindtitle from ld_approvereminds where ld_approvereminds.id=var_id;
				update ld_approvereminds set remindtitle = concat('【{modulelabel}】审批结果提醒') where ld_approvereminds.id=var_id and (remindtitle is null or remindtitle='' or remindtitle=@remindtitle);
			elseif var_type=2 THEN
				select  remindtitle = concat('【',@modulename,'】审批结果提醒') into @remindtitle from ld_approvereminds where ld_approvereminds.id=var_id;
				update ld_approvereminds set remindtitle = concat('【{modulelabel}】审批结果提醒') where ld_approvereminds.id=var_id and (remindtitle is null or remindtitle='' or remindtitle=@remindtitle);
			end if;
	end if;
   Fetch cur1 into var_id,var_type,var_reminduser,var_remindmethod, var_title,var_tabid;
	end while loop1;
	close cur1;
end ||
delimiter;

CALL ldcrm_approvereminds_remindtitle_add();
DROP PROCEDURE IF EXISTS `ldcrm_approvereminds_remindtitle_add`;
delimiter;
-- 2022-07-11

CALl AddColumn('ld_attachmentstype','module_name','varchar','255','');
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

UPDATE ld_version SET old_version='V8.4.6.6.7',current_version='V8.4.6.6.7',remark='V8.4.6.6.7-20220711',wx_version='V8.4.6.6.6.1';
delimiter;