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

DROP PROCEDURE IF EXISTS `Del_ForeignKey`;
delimiter ||
CREATE  PROCEDURE `Del_ForeignKey`(
	tmp_tablename varchar(100),
	tmp_fkeyname varchar(100)
)
BEGIN

	IF EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE WHERE CONSTRAINT_NAME=tmp_fkeyname AND TABLE_NAME=tmp_tablename AND TABLE_SCHEMA=DATABASE()) THEN
		SET @execsql=CONCAT(' ALTER TABLE ',tmp_tablename, ' DROP FOREIGN KEY ',tmp_fkeyname);
		PREPARE stmt_execsql FROM @execsql; 
		EXECUTE stmt_execsql;
		DEALLOCATE PREPARE stmt_execsql;
	END IF;

end ||
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SubmitOpinions','提交意见','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SubmitOpinions' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SubmitOpinions','Submit opinions','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SubmitOpinions' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DuplicateCheckShowsHyperlink','查重字段显示超链接','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DuplicateCheckShowsHyperlink' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DuplicateCheckShowsHyperlink','The duplicate check field shows the hyperlink','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DuplicateCheckShowsHyperlink' and labeltype='fixedstr');
delimiter;

SET @maxtabid=(SELECT MAX(tabid) FROM ld_tab);
SET @maxtseq=(SELECT MAX(tabsequence) FROM ld_tab);
INSERT INTO ld_tab(tabid,`name`,presence,tabsequence,tablabel,printtab,description)
SELECT @maxtabid+1,'CustomEcharts',5,@maxtseq+1,'CustomEcharts',1,'CustomEcharts' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tab WHERE `name`='CustomEcharts');

select max(sequence) into @sequence from ld_parenttabrel where parenttabid=5;
insert into ld_parenttabrel (parenttabid,tabid,sequence,tab_tablename) select 5,@maxtabid+1,@sequence+1,'ld_tab' from dual where not exists(select 1 from ld_parenttabrel where tabid=@maxtabid+1 and tab_tablename='ld_tab');

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomEcharts');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_tab',@tabid,@tabid,'自定义统计图' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='zh' AND trantable='ld_tab');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_tab',@tabid,@tabid,'CustomEcharts' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='en' AND trantable='ld_tab');

INSERT INTO ld_modtracker_tabs(tabid,visible)
SELECT @tabid,1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_modtracker_tabs WHERE tabid=@tabid);

SET @i=0;
INSERT INTO ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,actionid,(@i:=@i+1) FROM ld_actionmapping
WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid) AND actionname IN ('index','Detailview','Create','EditView',
'Delete','Copy','Allocate','Share','Import','Export','ChangeCreator','CustomView');
delimiter;

update ld_tab set presence=0 where name="CustomEcharts";
select tabsequence into @tabsequence from ld_tab  where name="Customreport";
update ld_tab set tabsequence=tabsequence+1 where tabsequence>@tabsequence;
update ld_tab set tabsequence=@tabsequence+1 where name="CustomEcharts";

SET @i=0;
update ld_tab set tabsequence=(@i:=@i+1) order by tabsequence;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CustomEcharts','自定义统计图','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CustomEcharts' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CustomEcharts','Custom Echarts','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CustomEcharts' and Labeltype='fixedstr' and languagetype='en');
delimiter;
-- 2021-03-24

UPDATE ld_systems_deploy SET deploy_value=0 WHERE deploy_type=270 AND NOT EXISTS (SELECT 1 FROM ld_loginhistory);

SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype='Attachment' AND viewname='相册选择' LIMIT 1);
UPDATE ld_customview SET viewname='选择相册' WHERE cvid=@cvid;
SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype='Attachment' AND viewname='选择相册' LIMIT 1);
UPDATE ld_cvadvfilter SET `value`='选择相册' WHERE cvid=@cvid AND `value`='相册选择';
delimiter;

UPDATE ld_systems_deploy SET deploy_value=2 WHERE deploy_type=51;               

UPDATE ld_desk SET fieldlabel='Shows the hyperlink' WHERE labelbol= 'DuplicateCheckShowsHyperlink' AND Labeltype='fixedstr' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='显示超链接' WHERE labelbol= 'DuplicateCheckShowsHyperlink' AND Labeltype='fixedstr' AND languagetype='zh';
delimiter;

INSERT INTO ld_systems_deploy ( `deploy_value`, `deploy_type`, `description`, `setype`, `sequence`, `roottype`, `inputtype`, `presence`, `inputvalue`)
SELECT 0, 280, '显示超链接', '', 1, NULL, NULL, 1, NULL  FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=280);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','menustyle','菜单风格','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='menustyle' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','menustyle','Menu style','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='menustyle' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','lightcolorversion','浅色版','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='lightcolorversion' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','lightcolorversion','Light color version','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='lightcolorversion' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','darkversion','深色版','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='darkversion' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','darkversion','Dark version','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='darkversion' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','custom1','自定义','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='custom1' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','custom1','Custom','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='custom1' and Labeltype='fixedstr' and languagetype='en');
delimiter;

call AddColumn('ld_organizationdetails','menustyle','varchar','50',NULL);
update ld_organizationdetails set menustyle='dark',menuback_color='#18223d',menuhover_color='#2490f8' WHERE IFNULL(menustyle,'')<>'dark';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MENUBACKGROUNDCOLOR','菜单背景色','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='MENUBACKGROUNDCOLOR' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MENUBACKGROUNDCOLOR','Menu background color','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='MENUBACKGROUNDCOLOR' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MENUSELECTBACKGROUNDCOLOR','菜单选中背景色','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='MENUSELECTBACKGROUNDCOLOR' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MENUSELECTBACKGROUNDCOLOR','Menu select background color','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='MENUSELECTBACKGROUNDCOLOR' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RESTORETHEDEFAULT','恢复默认','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RESTORETHEDEFAULT' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RESTORETHEDEFAULT','Restore the default','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RESTORETHEDEFAULT' and Labeltype='fixedstr' and languagetype='en');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomEcharts');
update ld_tranlabel set fieldlabel="自定义统计图表" where languagetype="zh" and  tabid=@tabid;
delimiter;
-- 2021-03-26

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomEcharts');
delete from ld_profileallpermission where tabid=@tabid;
SET @i=0;
INSERT INTO ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,actionid,(@i:=@i+1) FROM ld_actionmapping
WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid) AND actionname IN
    ('index','Create','Delete','Allocate');
delimiter;

update ld_producttoolfield set datarange='permit' where columnname='productname'  and (datarange is null or datarange='');
delimiter;

call AddColumn('ld_templatesstuff','source','varchar','255','home');
delimiter;

call AddColumn('ld_customreport','approveallocatetype','int','11','0');
create table if not exists `ld_customecharts2user` (
	`report_id` int(11) DEFAULT NULL,
  `userid` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

call AddColumn('ld_producttoolfield','savedatabase','varchar','50','yes');
delimiter;
alter table ld_producttoolfield alter savedatabase set default 'yes';
update ld_producttoolfield set savedatabase = 'yes' where savedatabase is NULL;
update ld_producttoolfield set savedatabase = 'no' where (edit_permission = 1 or input_type = 1);
update ld_producttoolfield set savedatabase = 'yes' where input_type = 2;
delimiter;

call AddColumn('ld_tabdetailfield','savedatabase','varchar','50','yes');
delimiter;

alter table ld_tabdetailfield alter savedatabase set default 'yes';
update ld_tabdetailfield set savedatabase = 'yes' where savedatabase is NULL;
update ld_tabdetailfield set savedatabase = 'yes' where input_type = 2;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_related_detailfield` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `modulename` varchar(50) DEFAULT NULL,
  `trigger_columnname` varchar(50) DEFAULT NULL,
  `effect_columnname` varchar(50) DEFAULT NULL,
  `curmodule_columninfo` varchar(50) DEFAULT NULL,
  `fromvalue_type` varchar(50) DEFAULT 'column',
  `fromvalue_info` text,
  `frommodule` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

call AddColumn('ld_customreport_total_column','yaxisindex','int','11','0');
call AddColumn('ld_customreport','smcreatorid','int','11','0');
call AddColumn('ld_customreport','stat_approach','varchar','255','0');
call AddColumn('ld_customreport_group','sequence','int','11','0');
call AddColumn('ld_customreport_group','bigtype','varchar','255','0');
call AddColumn('ld_customreport','show_athome','varchar','255','0');
delimiter;

delete from ld_setscoperhigher where modulename="CustomEcharts";
delimiter;

CALL AddColumn('ld_option_module','withdetail','varchar',20,'yes');
delimiter;
update ld_option_module set withdetail='yes' where withdetail is null or withdetail='';
delimiter;
CALL AddColumn('ld_option_module','strictsourcebillcolums','varchar',255,'');
delimiter;

select tabid into @out_tabid from ld_tab where name='OutboundOrder';
select tabid into @in_tabid from ld_tab where name='Stock';
select case when deploy_value=1 then '' else 'quantity' end  into @strictsourcebillcolums from 
ld_systems_deploy where deploy_type=10 and presence=0;
update ld_option_module set strictsourcebillcolums=@strictsourcebillcolums
where exists(select  1 from ld_systems_deploy where deploy_type=10 and presence=0)
and (tabid=@out_tabid or tabid=@in_tabid);
delimiter;

update ld_systems_deploy set presence=1 where deploy_type=10;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AutoWithProductDetail','自动带出源单产品管理分录','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='AutoWithProductDetail' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AutoWithProductDetail','Automatically bring out the source document product management entry','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='AutoWithProductDetail' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','StrictSourceBillColumn','严格参照源单（{columnname}不允许超出源单）','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='StrictSourceBillColumn' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','StrictSourceBillColumn','Strictly according to the original order （{columnname} amount is not allowed to exceed the tax-inclusive amount of the order ）','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='StrictSourceBillColumn' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','StrictSourceBillColumn','严格参照源单（{columnname}不允许超出源单）','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='StrictSourceBillColumn' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LineTipStrictSourceBillColumn','每行{productnamelabel}{columnname}不允许超出源单或者出现源单外的{productnamelabel}','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='LineTipStrictSourceBillColumn' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LineTipStrictSourceBillColumn','The {columnname} of each line product is not allowed to exceed the {columnname} of the order and foreign products are not allowed to appear','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='LineTipStrictSourceBillColumn' and labeltype='fixedstr');
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,inputtype,presence,inputvalue)
select '',279,'设置严格参照源单的字段',1,'select',1 ,'[{"value":"quantity","text":"StrictSourceBillColumn"},{"value":"tax_amount","text":"StrictSourceBillColumn"},{"sql":""}]'
from dual where not exists(select 1 from ld_systems_deploy where deploy_type=279);
delimiter;
update  ld_option_module INNER JOIN ld_tabdetailfield
on ld_tabdetailfield.tabid=ld_option_module.tabid
set withdetail='no';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SaveBillStrictSourceTip','<span style="color:black;line-height:40px;height:40px">单据没有严格参照源单录入数据，请修改之后，重新保存，其中：</span><br>####第{n}行{productname}####录入:{columnname_deskvalue}->实际:{columnname_dbvalue},####','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='SaveBillStrictSourceTip' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SaveBillStrictSourceTip','<span style="color:black;line-height:40px;height:40px">单据没有严格参照源单录入数据，请修改之后，重新保存，其中：</span><br>，其中####第{n}行{productname}####录入:{columnname_deskvalue}->实际:{columnname_dbvalue},####','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='SaveBillStrictSourceTip' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SaveBillStrictSourceNotEmptyTip','第{n}行,请严格参照源单,不能录入源单以外的产品','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='SaveBillStrictSourceNotEmptyTip' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SaveBillStrictSourceNotEmptyTip','第{n}行,请严格参照源单,不能录入源单以外的产品','fixedstr' from dual 
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='SaveBillStrictSourceNotEmptyTip' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','StrictReferenceSourceBill','请严格参照源单录入数据','jspop' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='StrictReferenceSourceBill' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','StrictReferenceSourceBill','请严格参照源单录入数据','jspop' from dual 
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='StrictReferenceSourceBill' and labeltype='jspop');
delimiter;
-- 2021-03-31


update ld_producttoolfield set allowhide='no' where columnname='paperquantity';
delimiter;

CALL Del_ForeignKey('ld_parenttabrel', 'ld_parenttabrel_ibfk_2');
delimiter;

update ld_systems_deploy set presence=1,roottype=0 where deploy_type=10;
delimiter;

update ld_systems_deploy set presence=0,roottype='' where deploy_type=279;
delimiter;
-- 2021-04-02

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

UPDATE ld_version SET old_version='V8.4.2.1',current_version='V8.4.2.1',remark='V8.4.2.1-20210402',wx_version='V8.4.2.1';
delimiter;