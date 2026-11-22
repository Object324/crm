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


SET @labelbol = 'SearchForRelevantInformation';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'搜索相关信息',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Search For Relevant Information',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'noRecord';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'暂无数据',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'no Record',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

update ld_desk set fieldlabel='确定要删除所有搜索历史吗？' where labelbol = 'menudeletesearchhistorytip' and labeltype='jspop' and languagetype = 'zh';
update ld_desk set fieldlabel='Are you sure you want to delete all search history?' where labelbol = 'menudeletesearchhistorytip' and labeltype='jspop' and languagetype = 'en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','beforeoperationthisrecord4','该单据未审批通过，不允许升级为"{Module}"单据！','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='beforeoperationthisrecord4' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','beforeoperationthisrecord4','This document has not been approved and cannot be upgraded to a "{Module}" document!','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='beforeoperationthisrecord4' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ZHUHUABASICEDITION','助华基础版','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ZHUHUABASICEDITION' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ZHUHUABASICEDITION',"Zhuhua Basic Edition",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ZHUHUABASICEDITION' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ZHUHUAENHANCEDEDITION','助华增强版','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ZHUHUAENHANCEDEDITION' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ZHUHUAENHANCEDEDITION',"Zhuhua Enhanced Edition",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ZHUHUAENHANCEDEDITION' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ZHUHUASERVICEENHANCEDEDITION','助华服务增强版','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ZHUHUASERVICEENHANCEDEDITION' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ZHUHUASERVICEENHANCEDEDITION',"Zhuhua Service Enhanced Edition",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ZHUHUASERVICEENHANCEDEDITION' and labeltype='fixedstr');
delimiter;

SET @labelbol = 'DISPALYATLEASTONE';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'至少显示一个字段',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Display at least one field',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'DISPALYATLEASTONE';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'至少显示一个字段',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Display at least one field',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ld_global_ui_setting','全局布局样式定制','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ld_global_ui_setting' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ld_global_ui_setting',"Global layout style customization",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ld_global_ui_setting' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ld_listview_top_ui_setting','列表页-筛选区域样式','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ld_listview_top_ui_setting' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ld_listview_top_ui_setting',"list page-filter area style",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ld_listview_top_ui_setting' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ld_listview_tabel_ui_setting','列表页-表格显示样式','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ld_listview_tabel_ui_setting' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ld_listview_tabel_ui_setting',"list page-table display style",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ld_listview_tabel_ui_setting' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ld_detailview_detail_ui_setting','详情页-详细信息中字段排列样式','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ld_detailview_detail_ui_setting' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ld_detailview_detail_ui_setting',"detail page-field arrangement style in details page",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ld_detailview_detail_ui_setting' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ld_leftmenu_uisetting_tips','CRM菜单按照所设置布局展示','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ld_leftmenu_uisetting_tips' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ld_leftmenu_uisetting_tips',"CRM menu display according to the set layout",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ld_leftmenu_uisetting_tips' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','dropdown_menu','下拉式菜单','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='dropdown_menu' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','dropdown_menu',"drop-down menu",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='dropdown_menu' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','hoverselect_menu','悬浮选择式菜单','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='hoverselect_menu' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','hoverselect_menu',"hover select menu",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='hoverselect_menu' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ld_listviewtop_uisetting_tips','拥有筛选、搜索和按钮的所有模块列表,均按照所设置布局展示','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ld_listviewtop_uisetting_tips' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ld_listviewtop_uisetting_tips',"all module lists with filters, searches and buttons display according to the set layout",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ld_listviewtop_uisetting_tips' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ld_listviewtable_uisetting_tips','所有模块的列表页表格信息字段,均按照所设置布局展示','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ld_listviewtable_uisetting_tips' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ld_listviewtable_uisetting_tips',"all module list page form information fields display according to the set layout",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ld_listviewtable_uisetting_tips' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ld_detailview_uisetting_tips','所有模块的详情页详细信息中字段,均按照所设置布局展示','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ld_detailview_uisetting_tips' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ld_detailview_uisetting_tips',"The fields in the details page of all modules are displayed according to the set layout",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ld_detailview_uisetting_tips' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','searchleftbuttonright','搜索左下,按钮右上','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='searchleftbuttonright' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','searchleftbuttonright'," Search bottom-left button top-right",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='searchleftbuttonright' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','searchbuttonleft','搜索和按钮同在左下','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='searchbuttonleft' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','searchbuttonleft'," search and button on the same bottom-left",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='searchbuttonleft' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','searchrightbuttonleft','搜索右上,按钮左下','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='searchrightbuttonleft' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','searchrightbuttonleft'," search top-right button bottom-left",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='searchrightbuttonleft' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','splitline','横竖分割线分割','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='splitline' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','splitline',"horizontal and vertical split line split",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='splitline' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','splitcolor','隔行换色分割','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='splitcolor' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','splitcolor',"color change split",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='splitcolor' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','splitcolorandline','横竖分割线隔行换色分割','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='splitcolorandline' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','splitcolorandline',"horizontal and vertical split line split, color change split",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='splitcolorandline' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','detailsplitline','分割线分割','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='detailsplitline' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','detailsplitline',"split line split, color change split",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='detailsplitline' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','detailsplitcolor','隔行换色分割','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='detailsplitcolor' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','detailsplitcolor'," color change split",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='detailsplitcolor' and labeltype='fixedstr');
delimiter;

select blockid into @blockid from ld_settings_blocks where label='LBI_UI_SETTINGS';
select sequence into @sequence from ld_settings_field where blockid=@blockid and name='LBL_LOGIN_SETTINGS';
select max(fieldid) into @fieldid from ld_settings_field;
update ld_settings_field set sequence=sequence+2 where blockid=@blockid and sequence>@sequence;
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @fieldid+1,@blockid,'ld_global_ui_setting','','全局布局样式定制','index.php?module=Settings&action=globaluisetting&mode=listview&parenttab=Settings',@sequence+1,0 from DUAL
where not exists(select 1 from ld_settings_field where blockid = @blockid and `name` = 'ld_global_ui_setting');
set @i=0;
update ld_settings_field set sequence=(@i:=@i+1) where blockid=@blockid order by sequence;
delimiter;

set @deploy_type = 484;
INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
SELECT 3,@deploy_type,'列表页表格界面定制','',0,'','text',0,'' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@deploy_type);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PleaseSaveVarFirst','请先保存{Var}','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PleaseSaveVarFirst' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PleaseSaveVarFirst','Please save {Var} first','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PleaseSaveVarFirst' and labeltype='jspop' and languagetype='en');
delimiter;

UPDATE ld_listview_btn SET btntype = 'rely' WHERE `name` = 'Export' and btntype = 'both';
delimiter;

SET @labelbol = 'HIDEGROUP';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'隐藏部门',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Hide Group',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'SUREWANTHIDE';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'确定要隐藏吗？',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Sure you want to hide?',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'HIDEGROUP';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'隐藏部门',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Hide group',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'CANNOTHIDE';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'有客户未离职，无法隐藏该部门',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Cannot hide this group because there exist customers who have not yet resigned',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'RECOVERGROUP';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'恢复隐藏部门',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Recover hidden group',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'HIDDEN';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'隐藏',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Hidden',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

CALL AddColumn('ld_groups','is_hidden','varchar','5','no');
ALTER TABLE ld_groups ALTER COLUMN is_hidden SET DEFAULT 'no';
UPDATE ld_groups set is_hidden = 'no' where is_hidden is NULL;
delimiter;

UPDATE ld_systems_deploy SET inputvalue = '[{"value":"none","text":"NotHandled"},{"value":"all","text":"ALL"},{"value":"part","text":"AllocateSharePart"},{"sql":""},{"relatedmodule":"Accounts"}]' WHERE deploy_type in (26,61);
delimiter;

UPDATE ld_systems_deploy SET deploy_value = CASE
    WHEN deploy_value = 1 THEN 'none'
    WHEN deploy_value = 0 THEN
        (CASE WHEN EXISTS (
                SELECT 1 FROM ld_module_setting_byuser WHERE ld_module_setting_byuser.`label` IN ('SeniorShare', 'seniorAllocate', 'seniorAverageAllocate', 'seniorHigndistribution', 'seniorAverageHigndistribution') AND ld_module_setting_byuser.`content` like '%"relmodule_scope":"part"%'
            ) THEN 'part'
            ELSE 'all'
        END)
    ELSE deploy_value
END
WHERE deploy_type in (26,61);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NotHandled','不处理','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NotHandled' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NotHandled','Not handled','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NotHandled' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AllocateSharePart','分配/共享部分','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AllocateSharePart' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AllocateSharePart','Allocate/Share part','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AllocateSharePart' and labeltype='fixedstr' and languagetype='en');
delimiter;

UPDATE ld_desk set fieldlabel='同时{Var}以下相关信息' WHERE labelbol='SimultaneouslyVarRelinfo' and languagetype='zh' and labeltype='fixedstr';
UPDATE ld_desk set fieldlabel='Simultaneously {Var} the following relevant information' WHERE labelbol='SimultaneouslyVarRelinfo' and languagetype='en' and labeltype='fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DonotVarRelinfo','不{Var}相关信息','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DonotVarRelinfo' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DonotVarRelinfo','Do not {Var} relevant information','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DonotVarRelinfo' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','IncludeRelInfoDocuments','同时共享相关信息单据 %d 条，成功 %d 条，失败 %d 条。','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='IncludeRelInfoDocuments' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','IncludeRelInfoDocuments','This includes %d relevant information documents,%d successful, %d failed.','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='IncludeRelInfoDocuments' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ShareLogLabel2','{Module} {Var}，移除团队成员：{Var2}','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ShareLogLabel2' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ShareLogLabel2','{Module} {Var},remove team members: {Var2}','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ShareLogLabel2' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ShareLogLabel3','{Module} {Var}，添加团队成员：{Var3}','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ShareLogLabel3' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ShareLogLabel3','{Module} {Var},add team members: {Var3}','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ShareLogLabel3' and labeltype='fixedstr' and languagetype='en');
delimiter;

UPDATE ld_crmlog_share SET operationdetails = 'ShareLogLabel2' WHERE shareto_userids = '' AND remove_userids <> '';
UPDATE ld_crmlog_share SET operationdetails = 'ShareLogLabel3' WHERE remove_userids = '' AND shareto_userids <> '';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASEFILLFORMAT','请填写允许上传的文件格式，如：jpg，png','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PLEASEFILLFORMAT' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASEFILLFORMAT','Please fill in the allowed file formats for uploading, such as jpg, png, png','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PLEASEFILLFORMAT' and labeltype='jspop' and languagetype='en');
delimiter;

SET @labelbol = 'HomepageBannerImageSetting';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'首页横幅图片设置',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Homepage Banner Image Setting',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;


SET @labelbol = 'RecommendedSizeRatioBanner';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'建议尺寸比例：2*1(宽*高)，图片名称禁用汉字及中文特殊字符',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Recommended size ratio: 2*1 (width*height), Chinese characters and Chinese special characters are prohibited in the picture name',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'ChooseNewBackground';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'选择新背景',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Choose a new background',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

set @tabid=(select tabid from ld_tab where `name`='ModComments');
update ld_field set tablename = 'ld_modcomments' where tabid=@tabid and fieldname='image' and uitype=69;
call AddColumn('ld_modcomments','image','text','','');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASESELECTEMAIL','请选择Email','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PLEASESELECTEMAIL' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASESELECTEMAIL',"Please select the Email",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PLEASESELECTEMAIL' and labeltype='jspop');
delimiter;

DROP PROCEDURE IF EXISTS `InsertSigninRelatedList`;
delimiter ||
CREATE PROCEDURE InsertSigninRelatedList(IN tab_name VARCHAR(255))
BEGIN
    DECLARE tmp_tabid INT;
    DECLARE tmp_related_tabid INT;
    DECLARE tmp_sequence INT;
    DECLARE tmp_mobile_sequence INT;
    DECLARE tmp_wx_sequence INT;
    DECLARE tmp_maxrelation_id INT;

    SET tmp_tabid = (SELECT tabid FROM ld_tab WHERE name = tab_name);

    SET tmp_related_tabid = (SELECT tabid FROM ld_tab WHERE name = 'Singin');
    
    SET tmp_sequence = (SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid = tmp_tabid);
    SET tmp_mobile_sequence = (SELECT MAX(mobile_sequence) FROM ld_relatedlists WHERE tabid = tmp_tabid);
    SET tmp_wx_sequence = (SELECT MAX(wx_sequence) FROM ld_relatedlists WHERE tabid = tmp_tabid);
    SET tmp_maxrelation_id = (SELECT MAX(relation_id) FROM ld_relatedlists);

		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,mobile_sequence,type,related_coltable,wx_presence,wx_sequence,buttonstatus)
		SELECT tmp_maxrelation_id+1,tmp_tabid,tmp_related_tabid,'get_singin_list',tmp_sequence+1,'Singin',1,'',1,tmp_mobile_sequence+1,'signin_datacategory_sql','tmpsourcedetail.id',1,tmp_wx_sequence+1,'no' FROM DUAL
		WHERE not exists(select 1 from ld_relatedlists where tabid=tmp_tabid and related_tabid=tmp_related_tabid and label = 'Singin');

END ||
delimiter;
CALL InsertSigninRelatedList('Potentials');
CALL InsertSigninRelatedList('Products');
CALL InsertSigninRelatedList('HelpDesk');
CALL InsertSigninRelatedList('Campaigns');
CALL InsertSigninRelatedList('Leads');
DROP PROCEDURE IF EXISTS `InsertSigninRelatedList`;
delimiter;


insert into ld_wx_config (name,description) select 'electronic_signature_fdd','法大大电子签章' from dual where not exists(select 1 from ld_wx_config where name='electronic_signature_fdd');
delimiter;
CALL AddColumn('ld_salesorder_electronicsignet','platform','varchar','50','');
CALL AddColumn('ld_salesorder_electronicsignet','flowstatus_en','varchar','50','');
ALTER TABLE ld_salesorder_electronicsignet MODIFY COLUMN flowstatus_en varchar(50) AFTER flowstatus;
delimiter;

update ld_desk set fieldlabel = 'Sensitive Information - Data encryption' where labeltype = 'fixedstr' and labelbol = 'SensitiveAllEncrypted' and languagetype = 'en';
update ld_desk set fieldlabel = '敏感信息-数据加密' where labeltype = 'fixedstr' and labelbol = 'SensitiveAllEncrypted' and languagetype = 'zh';
delimiter;

set @tmp_update = (select 1 from ld_settings_blocks where label='HOMEPAGE');
set @blockid = (select max(blockid) from ld_settings_blocks);
update ld_settings_blocks set sequence =
                                  case
                                      when @tmp_update = 1 then sequence
                                      else sequence + 1 end;
insert into ld_settings_blocks(blockid,label,sequence,active,inactive_icon,active_icon)
select @blockid+1,'HOMEPAGE',1,0,'HOMEPAGE.png','HOMEPAGE_hover.png' from dual
where not exists(select 1 from ld_settings_blocks where label='HOMEPAGE');
set @i=0;
update ld_settings_blocks set sequence=(@i:=@i+1) order by sequence;
delimiter;

select blockid into @blockid from ld_settings_blocks where label='HOMEPAGE';
select max(fieldid) into @fieldid from ld_settings_field;
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @fieldid+1,@blockid,'HOMEPAGE','','系统配置引导页','index.php?module=Settings&action=settings_homepage&mode=listview&parenttab=Settings',1,0 from dual
where not exists(select 1 from ld_settings_field where blockid = @blockid and `name` = 'HOMEPAGE');
set @i=0;
update ld_settings_field set sequence=(@i:=@i+1) where blockid=@blockid order by sequence;
delimiter;

SET @labelbol = 'BASICSETTINGS';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'基础设置',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Basic settings',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'BUSINESSCONFIGURATION';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'业务配置',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Business Configuration',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'ENTERPRISESETTINGS';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'企业设置',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Enterprise Settings',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'STRUCTUREMANAGEMENT';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'组织架构管理',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Organizational structure management',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'PRIVILEGEMANAGEMENT';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'角色权限管理',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Role Privilege Management',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'INTERFACEMANAGEMENT';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'界面定制管理',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Interface customization management',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'PROCESSMANAGEMENT';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'流程管理',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'process management',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'DATARIGHTSMANAGEMENT';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'数据权限管理',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Data Rights Management',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'BUSINESSRULESMANAGEMENT';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'业务规则管理',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Business rules management',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'BUSINESSNAMEANDLOGOSETTINGS';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'企业名称、logo等基础设置',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Basic settings such as business name and logo',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'ACCOUNTLOGINSECURITYSETTINGS';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'账号登录安全性设置',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Account Login Security Settings',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'ENTERINGEMPLOYEESANDDEPARTMENTS';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'录入员工与部门',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Entering Employees and Departments',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'EMPLOYEELOGINMETHODCONTROL';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'员工登录方式控制',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Employee Login Method Control',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'EMPLOYEEMODULEPERMISSIONSETTINGS';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'员工模块权限设置',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Employee Module Permission Settings',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'EMPLOYEEDATASCOPESETTINGS';
SET @labeltype = 'fixedstr';

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'zh', @labelbol, '员工数据范围设置', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'zh' AND labelbol = @labelbol AND labeltype = @labeltype
);

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'en', @labelbol, 'Employee Data Scope Settings', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'en' AND labelbol = @labelbol AND labeltype = @labeltype
);

delimiter;

SET @labelbol = 'PCMENUMANAGEMENTSETTINGS';
SET @labeltype = 'fixedstr';

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'zh', @labelbol, '电脑端菜单管理设置', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'zh' AND labelbol = @labelbol AND labeltype = @labeltype
);

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'en', @labelbol, 'PC Menu Management Settings', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'en' AND labelbol = @labelbol AND labeltype = @labeltype
);

delimiter;

SET @labelbol = 'PCHOMEPAGECUSTOMIZATION';
SET @labeltype = 'fixedstr';

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'zh', @labelbol, '电脑端首页定制', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'zh' AND labelbol = @labelbol AND labeltype = @labeltype
);

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'en', @labelbol, 'PC Homepage Customization', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'en' AND labelbol = @labelbol AND labeltype = @labeltype
);

delimiter;

SET @labelbol = 'MOBILEFUNCTIONMENUMANAGEMENTSETTINGS';
SET @labeltype = 'fixedstr';

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'zh', @labelbol, '移动端功能菜单管理设置', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'zh' AND labelbol = @labelbol AND labeltype = @labeltype
);

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'en', @labelbol, 'Mobile Function Menu Management Settings', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'en' AND labelbol = @labelbol AND labeltype = @labeltype
);

delimiter;

SET @labelbol = 'MOBILEWORKBENCHCUSTOMIZATION';
SET @labeltype = 'fixedstr';

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'zh', @labelbol, '移动端工作台定制', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'zh' AND labelbol = @labelbol AND labeltype = @labeltype
);

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'en', @labelbol, 'Mobile Workbench Customization', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'en' AND labelbol = @labelbol AND labeltype = @labeltype
);

delimiter;

SET @labelbol = 'SYSTEMMODULEMANAGEMENT';
SET @labeltype = 'fixedstr';

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'zh', @labelbol, '系统模块管理', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'zh' AND labelbol = @labelbol AND labeltype = @labeltype
);

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'en', @labelbol, 'System Module Management', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'en' AND labelbol = @labelbol AND labeltype = @labeltype
);

delimiter;

SET @labelbol = 'MODULETEMPLATESETTINGS';
SET @labeltype = 'fixedstr';

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'zh', @labelbol, '模块模板设置', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'zh' AND labelbol = @labelbol AND labeltype = @labeltype
);

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'en', @labelbol, 'Module Template Settings', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'en' AND labelbol = @labelbol AND labeltype = @labeltype
);

delimiter;

SET @labelbol = 'RICHTEXTCONTENTTEMPLATESETTINGS';
SET @labeltype = 'fixedstr';

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'zh', @labelbol, '富文本内容模板设置', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'zh' AND labelbol = @labelbol AND labeltype = @labeltype
);

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'en', @labelbol, 'Rich Text Content Template Settings', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'en' AND labelbol = @labelbol AND labeltype = @labeltype
);

delimiter;

SET @labelbol = 'WORKREPORTTEMPLATECUSTOMIZATION';
SET @labeltype = 'fixedstr';

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'zh', @labelbol, '工作汇报模板定制', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'zh' AND labelbol = @labelbol AND labeltype = @labeltype
);

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'en', @labelbol, 'Work Report Template Customization', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'en' AND labelbol = @labelbol AND labeltype = @labeltype
);

delimiter;

SET @labelbol = 'APPROVALFLOWSETTINGS';
SET @labeltype = 'fixedstr';

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'zh', @labelbol, '审批流设置', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'zh' AND labelbol = @labelbol AND labeltype = @labeltype
);

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'en', @labelbol, 'Approval Flow Settings', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'en' AND labelbol = @labelbol AND labeltype = @labeltype
);

delimiter;

SET @labelbol = 'WORKFLOWSETTINGS';
SET @labeltype = 'fixedstr';

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'zh', @labelbol, '工作流设置', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'zh' AND labelbol = @labelbol AND labeltype = @labeltype
);

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'en', @labelbol, 'Workflow Settings', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'en' AND labelbol = @labelbol AND labeltype = @labeltype
);

delimiter;

SET @labelbol = 'MEMBERDATAPERMISSIONMANAGEMENT';
SET @labeltype = 'fixedstr';

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'zh', @labelbol, '成员数据权限管理', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'zh' AND labelbol = @labelbol AND labeltype = @labeltype
);

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'en', @labelbol, 'Member Data Permission Management', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'en' AND labelbol = @labelbol AND labeltype = @labeltype
);

delimiter;

SET @labelbol = 'MODULEDATASHARINGMANAGEMENT';
SET @labeltype = 'fixedstr';

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'zh', @labelbol, '模块数据共享管理', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'zh' AND labelbol = @labelbol AND labeltype = @labeltype
);

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'en', @labelbol, 'Module Data Sharing Management', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'en' AND labelbol = @labelbol AND labeltype = @labeltype
);

delimiter;

SET @labelbol = 'SALESCLUEPUBLICPOOLMANAGEMENT';
SET @labeltype = 'fixedstr';

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'zh', @labelbol, '销售线索公海池管理', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'zh' AND labelbol = @labelbol AND labeltype = @labeltype
);

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'en', @labelbol, 'Sales Clue Public Pool Management', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'en' AND labelbol = @labelbol AND labeltype = @labeltype
);

delimiter;

SET @labelbol = 'CUSTOMERMANAGEMENTPUBLICPOOLMANAGEMENT';
SET @labeltype = 'fixedstr';

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'zh', @labelbol, '客户管理公海池管理', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'zh' AND labelbol = @labelbol AND labeltype = @labeltype
);

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
SELECT 'en', @labelbol, 'Customer Management Public Pool Management', @labeltype
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM ld_desk
    WHERE languagetype = 'en' AND labelbol = @labelbol AND labeltype = @labeltype
);
delimiter;

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'accountset','self','客户公海参数设置','' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'accountset');
delimiter;

UPDATE ld_cvcolumnlist SET columnname = 'ld_employment:employment_joineddate:employment_joineddate:Employment_fieldlabel:D' WHERE columnname = 'ld_employment:employment_joineddate:employment_joineddate:Employment_fieldlabel:DT';
UPDATE ld_cvcolumnlist SET columnname = 'ld_employment:employment_expirationdate:employment_expirationdate:Employment_fieldlabel:D' WHERE columnname = 'ld_employment:employment_expirationdate:employment_expirationdate:Employment_fieldlabel:DT';
delimiter;

UPDATE ld_cvcolumnlist SET columnname = 'ld_resignation:smownerid:assigned_user_id:Resignation_fieldlabel:V' WHERE columnname = 'ld_resignation:Smownerid:assigned_user_id:Resignation_fieldlabel:V';
UPDATE ld_cvcolumnlist SET columnname = 'ld_resignation:resignation_resigndate:resignation_resigndate:Resignation_fieldlabel:D' WHERE columnname = 'ld_resignation:resignation_resigndate:resignation_resigndate:Resignation_fieldlabel:DT';
UPDATE ld_cvcolumnlist SET columnname = 'ld_resignation:resignation_handover:resignation_handover:Resignation_fieldlabel:C' WHERE columnname = 'ld_resignation:resignation_handover:resignation_handover:Resignation_fieldlabel:V';
delimiter;

UPDATE ld_cvcolumnlist SET columnname = 'ld_evaluation:evaluation_score:evaluation_score:Evaluation_fieldlabel:NN' WHERE columnname = 'ld_evaluation:evaluation_score:evaluation_score:Evaluation_fieldlabel:N';
delimiter;

UPDATE ld_desk SET fieldlabel = '横竖分割线+隔行换色结合' where labelbol = 'splitcolorandline' AND labeltype = 'fixedstr' AND languagetype = 'zh';
delimiter;

CALL AddColumn('ld_homestuffdetail','groupby','varchar','255','');

update ld_homestuffdetail set groupby=viewrange where stuffid=100 and ifnull(groupby,'')='';
delimiter;

UPDATE ld_desk set fieldlabel='全部数据范围的相关信息' WHERE labelbol='ChangeAllData' and languagetype='zh' and labeltype='fixedstr';
UPDATE ld_desk set fieldlabel='Relevant information on the entire data range' WHERE labelbol='ChangeAllData' and languagetype='en' and labeltype='fixedstr';
delimiter;

UPDATE ld_desk set fieldlabel='与{Module}相同{Var}的相关信息' WHERE labelbol='OnlyChangeSameVarData' and languagetype='zh' and labeltype='fixedstr';
UPDATE ld_desk set fieldlabel='Only change the relevant information with the same {Var} as {Module}' WHERE labelbol='OnlyChangeSameVarData' and languagetype='en' and labeltype='fixedstr';
delimiter;



DROP PROCEDURE IF EXISTS `ldcrm_reset_currencydefault`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_currencydefault`(
)
BEGIN

	DECLARE tmp_execsql TEXT DEFAULT NULL;

	DECLARE MYCUSOR CURSOR FOR 
		SELECT
			a.exe_sql
		FROM (
			SELECT
				TABLE_NAME,
				CONCAT("ALTER TABLE ",TABLE_NAME," MODIFY COLUMN currency_id INT(19) DEFAULT 1;") AS exe_sql
			FROM information_schema.COLUMNS
			WHERE TABLE_SCHEMA=DATABASE()
				AND COLUMN_NAME='currency_id'                   
				AND IFNULL(COLUMN_DEFAULT,0)=0
			UNION
			SELECT
				TABLE_NAME,
				CONCAT("ALTER TABLE ",TABLE_NAME," MODIFY COLUMN currency_symbol VARCHAR(30) DEFAULT '¥';") AS exe_sql
			FROM information_schema.COLUMNS
			WHERE TABLE_SCHEMA=DATABASE()
				AND COLUMN_NAME='currency_symbol'                   
				AND IFNULL(COLUMN_DEFAULT,'')=''
			UNION
			SELECT
				TABLE_NAME,
				CONCAT("ALTER TABLE ",TABLE_NAME," MODIFY COLUMN conversion_rate DECIMAL(25,6) DEFAULT 1.000000;") AS exe_sql
			FROM information_schema.COLUMNS
			WHERE TABLE_SCHEMA=DATABASE()
				AND COLUMN_NAME='conversion_rate'                   
				AND IFNULL(COLUMN_DEFAULT,0)=0
		) a
		INNER JOIN (
			SELECT
				TABLE_NAME,
				COUNT(DISTINCT COLUMN_NAME) AS CNT
			FROM information_schema.COLUMNS
			WHERE TABLE_SCHEMA=DATABASE()
				AND COLUMN_NAME IN ('currency_id','currency_symbol','conversion_rate')
			GROUP BY TABLE_NAME
			HAVING COUNT(DISTINCT COLUMN_NAME)=3
		) b ON b.TABLE_NAME=a.TABLE_NAME;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_execsql = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_execsql;
	WHILE(tmp_execsql IS NOT NULL) DO
		SET @this_execsql=tmp_execsql;
		PREPARE mystmt FROM @this_execsql;
		EXECUTE mystmt;
		DEALLOCATE PREPARE mystmt;

		FETCH MYCUSOR INTO tmp_execsql;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

CALL ldcrm_reset_currencydefault();
DROP PROCEDURE IF EXISTS `ldcrm_reset_currencydefault`;
delimiter;

update ld_desk set fieldlabel='可以看到其他成员单据列表的情况下是否有权限查看其他成员的单据详情' where languagetype='zh' and labelbol='viewothers' and labeltype='fixedstr';
update ld_desk set fieldlabel="Whether one has the permission to view the details of other members' documents when they can see the list of documents from other members" where languagetype='en' and labelbol='viewothers' and labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel='可以看到"负责人"是其他成员的单据列表的情况下，是否有权限仅查看"创建人"字段是自己的单据详情' where languagetype='zh' and labelbol='ViewCreateMeTip' and labeltype='fixedstr';
update ld_desk set fieldlabel='Whether one has the permission to view the details of documents where the "Person in Charge" is another member, but the "Creator" field belongs to oneself' where languagetype='en' and labelbol='ViewCreateMeTip' and labeltype='fixedstr';
delimiter;

SET @modulename = 'Resignation';
SET @tabid = (SELECT tabid FROM ld_tab where `name`=@modulename);
SET @trigger_fieldid = (SELECT fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'smownerid');
SET @effect_fieldid = (SELECT fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'resignation_group');
INSERT INTO ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT 'main',@trigger_fieldid,@effect_fieldid,'resignation_group','column','groupid','Users' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_related_field WHERE trigger_fieldid = @trigger_fieldid AND effect_fieldid=@effect_fieldid);
delimiter;

SET @modulename = 'Employment';
SET @tabid = (SELECT tabid FROM ld_tab where `name`=@modulename);
UPDATE ld_field SET uitype=152,bigtype='' WHERE tabid=@tabid and fieldname='employment_group' and uitype=180;
delimiter;

select max(blockid)+1 into @blockid from ld_settings_blocks;
insert into ld_settings_blocks(blockid,
	label,
	sequence,
	active,
	inactive_icon,
	active_icon)
select
		@blockid,
		'CUSTOMIZED_DEALER_CHANNELS',
		@blockid,
		0,
		'LBL_SERVICE_MINI_SETTINGS.png',
		'LBL_SERVICE_MINI_SETTINGS_hover.png' from dual
where not exists(select 1 from ld_settings_blocks where label='CUSTOMIZED_DEALER_CHANNELS');
delimiter;

SET @labelbol = 'CUSTOMIZED_DEALER_CHANNELS';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'经销商渠道定制',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Reseller Channel Customisation',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

select max(fieldid) + 1 into @fieldid from ld_settings_field;
insert into ld_settings_field(fieldid,blockid,`name`,iconpath,description,linkto,sequence,active)
select  @fieldid,@blockid,'prm_web_customization','','','index.php?module=Settings&action=prmwebsettings&parenttab=Settings',1,0
from dual where not exists(select 1 from ld_settings_field where name='prm_web_customization');
delimiter;

SET @labelbol = 'prm_web_customization';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'web端界面定制',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'WEB Custom Page Customisation',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'Dealer_channel';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'经销商渠道',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Dealer channel ',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'home_settings';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'首页定制',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Customization of homepage',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'menu_settings';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'菜单定制',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Customization of menu',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'logo_settings';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'LOGO定制',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Customization of LOGO',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_prmparenttabrel`(
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tabid` int(19) NOT NULL,
  `sequence` int(3) NOT NULL,
  `tab_tablename` varchar(50) DEFAULT 'ld_tab',
  `checkphp` varchar(255) DEFAULT NULL,
  `isopeninblank` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;
delimiter;

call AddColumn('ld_organizationdetails','prmlogoname','varchar',100,'');
delimiter;

SET @labelbol = 'COMPANYCRMUSER';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'企业内部用户',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Intra-company Users',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'COMPANYPRMUSER';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'企业经销商用户',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Distributor Users',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

DROP PROCEDURE IF EXISTS `updatehistoryusergrouptype`;
delimiter ||
CREATE PROCEDURE `updatehistoryusergrouptype`(
)
BEGIN
    DECLARE field_exists INT;
    DECLARE current_db VARCHAR(64);

    SELECT DATABASE() INTO current_db;

    SELECT COUNT(*)
    INTO field_exists
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = current_db
    AND TABLE_NAME = 'ld_users'
    AND COLUMN_NAME = 'user_type';

    IF field_exists > 0 THEN

				ALTER TABLE ld_users CHANGE user_type crm_user_type VARCHAR(50);
    END IF;
end ||
delimiter;

CALL updatehistoryusergrouptype();
DROP PROCEDURE IF EXISTS `updatehistoryusergrouptype`;
delimiter;

update ld_settings_field set blockid = (select blockid from ld_settings_blocks where label = 'LBL_INTERFACE_SETTINGS') where `name` = 'zhiyuan_setting';
delimiter;

set @labelbol = 'SYSTEMCONFIGURATIONGUIDANCE';
set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'系统配置引导',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'System Configuration Guidance',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;


DELETE FROM ld_settings_blocks WHERE label='HOMEPAGE';
delimiter;

set @tmp_update = (select 1 from ld_settings_blocks where label='SYSTEMCONFIGURATIONGUIDANCE');
set @blockid = (select max(blockid) from ld_settings_blocks);
update ld_settings_blocks set sequence =
                                  case
                                      when @tmp_update = 1 then sequence
                                      else sequence + 1 end;
insert into ld_settings_blocks(blockid,label,sequence,active,inactive_icon,active_icon)
select @blockid+1,'SYSTEMCONFIGURATIONGUIDANCE',1,0,'HOMEPAGE.png','HOMEPAGE_hover.png' from dual
where not exists(select 1 from ld_settings_blocks where label='SYSTEMCONFIGURATIONGUIDANCE');
set @i=0;
update ld_settings_blocks set sequence=(@i:=@i+1) order by sequence;
delimiter;

DELETE FROM ld_settings_field WHERE `name`='HOMEPAGE';
delimiter;

select blockid into @blockid from ld_settings_blocks where label='SYSTEMCONFIGURATIONGUIDANCE';
select max(fieldid) into @fieldid from ld_settings_field;
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @fieldid+1,@blockid,'SYSTEMCONFIGURATIONGUIDANCE','','系统配置引导页','index.php?module=Settings&action=settings_homepage&mode=listview&parenttab=Settings',1,0 from dual
where not exists(select 1 from ld_settings_field where blockid = @blockid and `name` = 'SYSTEMCONFIGURATIONGUIDANCE');
set @i=0;
update ld_settings_field set sequence=(@i:=@i+1) where blockid=@blockid order by sequence;
delimiter;

CALL AddColumn('ld_btnset','is_active','varchar',20,null);
ALTER TABLE ld_btnset ALTER COLUMN is_active SET DEFAULT 'yes';
UPDATE ld_btnset set is_active = 'yes' where is_active is NULL;
delimiter;

CALL AddColumn('ld_btnset','btn_type','varchar',50,null);
UPDATE ld_btnset set btn_type = 'listbasicbtn' where btn_type is NULL;
delimiter;

set @i = (select max(sequence) from ld_systems_deploy where roottype=1);
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select "yes",485,'设置产品管理是否启用加入购物车功能 no:否，yes:是','Products',@i+1,1,'select',0,'[{"value":"yes","text":"YES"},{"value":"no","text":"NO"},{"sql":""}]' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type = 485);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',485,485,'设置{$Products.Products}是否启用加入购物车功能'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_systems_deploy' and tabid = 485 and relateid=485);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',485,485,'Set whether to enable the add to cart feature in {$Products.Products}'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_systems_deploy' and tabid = 485 and relateid=485);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Actionlinksetting','列表操作列按钮设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Actionlinksetting' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Actionlinksetting',"List operation column button setting",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Actionlinksetting' and labeltype='fixedstr');
delimiter;
-- 2024-08-14

update ld_settings_blocks set inactive_icon = 'CUSTOMIZED_DEALER_CHANNELS.png',active_icon = 'CUSTOMIZED_DEALER_CHANNELS_hover.png' where label = 'CUSTOMIZED_DEALER_CHANNELS';
delimiter;

CALL AddColumn('ld_stuff','showfields','text','','');

update ld_stuff set stufftype='customsheet' where stuffid in(10,11,12,13,14,15,16,17,25,26,27,28,29,30);


set @tabname ='Calendar';
select tabid into @tabid from ld_tab where `name`=@tabname;
select CONCAT('[',GROUP_CONCAT(CONCAT('"',tablename,':',columnname,':',fieldname,':',@tabname,'_fieldlabel:',SUBSTRING_INDEX(typeofdata,'~',1),'"')),']') into @fieldinfo
from ld_field where tabid=@tabid  and columnname in('subject','activitytype','smownerid')ORDER BY FIELD(columnname, 'subject','activitytype','smownerid');
update ld_stuff set showfields=@fieldinfo  where stuffid in (10,11,12);

set @tabname ='Accounts';
select tabid into @tabid from ld_tab where `name`=@tabname;

select CONCAT('[',GROUP_CONCAT(CONCAT('"',tablename,':',columnname,':',fieldname,':',@tabname,'_fieldlabel:',SUBSTRING_INDEX(typeofdata,'~',1),'"')),']') into @fieldinfo
from ld_field where tabid=@tabid  and columnname in('accountname','phone')ORDER BY FIELD(columnname, 'accountname','phone');
update ld_stuff set showfields=@fieldinfo  where stuffid in (13);

set @tabname ='Potentials';
select tabid into @tabid from ld_tab where `name`=@tabname;

select CONCAT('[',GROUP_CONCAT(CONCAT('"',tablename,':',columnname,':',fieldname,':',@tabname,'_fieldlabel:',SUBSTRING_INDEX(typeofdata,'~',1),'"')),']') into @fieldinfo
from ld_field where tabid=@tabid  and columnname in('potentialname','total','accountid')ORDER BY FIELD(columnname, 'potentialname','total','accountid');
update ld_stuff set showfields=@fieldinfo  where stuffid in (14);


set @tabname ='Quotes';
select tabid into @tabid from ld_tab where `name`=@tabname;

select CONCAT('[',GROUP_CONCAT(CONCAT('"',tablename,':',columnname,':',fieldname,':',@tabname,'_fieldlabel:',SUBSTRING_INDEX(typeofdata,'~',1),'"')),']') into @fieldinfo
from ld_field where tabid=@tabid  and columnname in('quote_no','total','accountid')ORDER BY FIELD(columnname, 'quote_no','total','accountid');
update ld_stuff set showfields=@fieldinfo  where stuffid in (15);

set @tabname ='SalesOrder';
select tabid into @tabid from ld_tab where `name`=@tabname;

select CONCAT('[',GROUP_CONCAT(CONCAT('"',tablename,':',columnname,':',fieldname,':',@tabname,'_fieldlabel:',SUBSTRING_INDEX(typeofdata,'~',1),'"')),']') into @fieldinfo
from ld_field where tabid=@tabid  and columnname in('salesorder_no','total','accountid')ORDER BY FIELD(columnname,'salesorder_no','total','accountid');
update ld_stuff set showfields=@fieldinfo  where stuffid in (16);

set @tabname ='Invoice';
select tabid into @tabid from ld_tab where `name`=@tabname;

select CONCAT('[',GROUP_CONCAT(CONCAT('"',tablename,':',columnname,':',fieldname,':',@tabname,'_fieldlabel:',SUBSTRING_INDEX(typeofdata,'~',1),'"')),']') into @fieldinfo
from ld_field where tabid=@tabid  and columnname in('invoice_no','total','accountid')ORDER BY FIELD(columnname,'invoice_no','total','accountid');
update ld_stuff set showfields=@fieldinfo  where stuffid in (17);

set @tabname ='Expense';
select tabid into @tabid from ld_tab where `name`=@tabname;

select CONCAT('[',GROUP_CONCAT(CONCAT('"',tablename,':',columnname,':',fieldname,':',@tabname,'_fieldlabel:',SUBSTRING_INDEX(typeofdata,'~',1),'"')),']') into @fieldinfo
from ld_field where tabid=@tabid  and columnname in('expense_no','expensedate','total','smownerid')ORDER BY FIELD(columnname, 'expense_no','expensedate','total','smownerid');
update ld_stuff set showfields=@fieldinfo  where stuffid in (26);

set @tabname ='CashBill';
select tabid into @tabid from ld_tab where `name`=@tabname;

select CONCAT('[',GROUP_CONCAT(CONCAT('"',tablename,':',columnname,':',fieldname,':',@tabname,'_fieldlabel:',SUBSTRING_INDEX(typeofdata,'~',1),'"')),']') into @fieldinfo
from ld_field where tabid=@tabid  and columnname in('cashbill_no','cashbilldate','total','smownerid')ORDER BY FIELD(columnname,'cashbill_no','cashbilldate','total','smownerid');
update ld_stuff set showfields=@fieldinfo  where stuffid in (27);

set @tabname ='SendCashBill';
select tabid into @tabid from ld_tab where `name`=@tabname;

select CONCAT('[',GROUP_CONCAT(CONCAT('"',tablename,':',columnname,':',fieldname,':',@tabname,'_fieldlabel:',SUBSTRING_INDEX(typeofdata,'~',1),'"')),']') into @fieldinfo
from ld_field where tabid=@tabid  and columnname in('sendcashbill_no','cashbilldate','total','smownerid')ORDER BY FIELD(columnname,'sendcashbill_no','cashbilldate','total','smownerid');
update ld_stuff set showfields=@fieldinfo  where stuffid in (28);


set @tabname ='CashDeposit';
select tabid into @tabid from ld_tab where `name`=@tabname;

select CONCAT('[',GROUP_CONCAT(CONCAT('"',tablename,':',columnname,':',fieldname,':',@tabname,'_fieldlabel:',SUBSTRING_INDEX(typeofdata,'~',1),'"')),']') into @fieldinfo
from ld_field where tabid=@tabid  and columnname in('cashdeposit_no','cashdepositdate','cashmoney','smownerid')ORDER BY FIELD(columnname,'cashdeposit_no','cashdepositdate','cashmoney','smownerid');
update ld_stuff set showfields=@fieldinfo  where stuffid in (29);

set @tabname ='PutCash';
select tabid into @tabid from ld_tab where `name`=@tabname;

select CONCAT('[',GROUP_CONCAT(CONCAT('"',tablename,':',columnname,':',fieldname,':',@tabname,'_fieldlabel:',SUBSTRING_INDEX(typeofdata,'~',1),'"')),']') into @fieldinfo
from ld_field where tabid=@tabid  and columnname in('putcash_no','putcashdate','cashmoney','smownerid')ORDER BY FIELD(columnname, 'putcash_no','putcashdate','cashmoney','smownerid');
update ld_stuff set showfields=@fieldinfo  where stuffid in (30);


set @tabname ='PaymentPlan';
select tabid into @tabid from ld_tab where `name`=@tabname;

select CONCAT('[',GROUP_CONCAT(CONCAT('"',tablename,':',columnname,':',fieldname,':',@tabname,'_fieldlabel:',SUBSTRING_INDEX(typeofdata,'~',1),'"')order by FIELD(columnname,'periodtime','amount','plandate','accountid')),']') into @fieldinfo
from ld_field where tabid=@tabid  and columnname in('periodtime','amount','plandate','accountid') ;

update ld_stuff set showfields=@fieldinfo  where stuffid in (25);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NODOWNLOADPREVIEWPREMISSION','没有下载预览权限','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NODOWNLOADPREVIEWPREMISSION' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NODOWNLOADPREVIEWPREMISSION','No download preview permission','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NODOWNLOADPREVIEWPREMISSION' and Labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_desk set fieldlabel='选择单选用户字段' where labelbol='SELECTUSER' and labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Select Single Choice User Field' where labelbol='SELECTUSER' and labeltype='fixedstr' and languagetype='en';
delimiter;

CALL AddColumn('ld_business_settings','fuzzyquerycontrol','text',null,null);
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetFuzzy','设置模糊查询规则','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SetFuzzy' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetFuzzy',"Set fuzzy query rules",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SetFuzzy' and labeltype='fixedstr');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','allowcancelbusiness','允许匹配注销企业','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='allowcancelbusiness' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','allowcancelbusiness',"Allow matching cancelled business",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='allowcancelbusiness' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','allowprivatebusiness','允许匹配个体工商户','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='allowprivatebusiness' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','allowprivatebusiness',"Allow matching individual business",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='allowprivatebusiness' and labeltype='fixedstr');
delimiter;

DROP PROCEDURE IF EXISTS addmobile_expensebudget;
delimiter ||
CREATE PROCEDURE addmobile_expensebudget()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM ld_tab WHERE mobilepresence='mobile,weixin' AND `name` = 'ExpenseBudget') THEN
        UPDATE ld_tab SET ld_tab.mobilepresence = 'mobile,weixin' WHERE ld_tab.`name` = 'ExpenseBudget';

        SELECT ld_appparenttab.blockid INTO @blockid FROM ld_appparenttab WHERE parenttab_label = 'OAForms';
        SELECT ld_tab.tabid INTO @tabid FROM ld_tab WHERE ld_tab.`name` = 'ExpenseBudget';
        SELECT ld_tab.tabid INTO @pre_tabid FROM ld_tab WHERE ld_tab.`name` = 'NormalApprove';

        SELECT IFNULL(b.sequence ,a.sequence) INTO @sequence
        FROM
            (SELECT MAX(ld_appparenttabrel.sequence)+1 AS sequence FROM ld_appparenttabrel WHERE ld_appparenttabrel.blockid = @blockid) a
        LEFT JOIN
            (SELECT ld_appparenttabrel.sequence FROM ld_appparenttabrel WHERE ld_appparenttabrel.blockid = @blockid AND ld_appparenttabrel.tabid = @pre_tabid) b ON 1=1;

        INSERT INTO ld_appparenttabrel(blockid,tabid,sequence,tab_tablename)
        SELECT @blockid,@tabid,@sequence,'ld_tab' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_appparenttabrel WHERE @blockid IS NOT NULL AND blockid=@blockid AND tabid=@tabid);

        DELETE FROM ld_cvcolumnlist_wx WHERE modulename = 'ExpenseBudget';
        INSERT INTO ld_cvcolumnlist_wx ( modulename, rownumber, listnumber, columnname, type, presence, systemdefault, showtag )
        VALUES
            ( 'ExpenseBudget', 1, 1, 'ld_expensebudget:expensebudget_no:expensebudget_no:ExpenseBudget_单据编号:V', 0, 0, 'yes', 'yes' ),
            ( 'ExpenseBudget', 3, 1, 'ld_expensebudget:smownerid:assigned_user_id:ExpenseBudget_负责人:V', 0, 0, 'yes', 'yes' ),
            ( 'ExpenseBudget', 2, 1, 'ld_expensebudget:total:hdnGrandTotal:ExpenseBudget_合计:N', 0, 0, 'yes', 'yes' );

        DELETE FROM ld_fieldwxmaininfo WHERE tabid = @tabid;
        INSERT INTO ld_fieldwxmaininfo ( tabid, fieldname, sequence, displaytype, presence, showtag)
        VALUES
            ( @tabid, 'expensebudget_no', 1, 'normal', 0, 'yes' ),
            ( @tabid, 'hdnGrandTotal', 2, 'normal', 0, 'yes'),
            ( @tabid, 'expensebudget_type', 3, 'normal', 0, 'yes'),
            ( @tabid, 'budget_start_date', 4, 'normal', 0, 'yes'),
            ( @tabid, 'budget_end_date', 5, 'normal', 0, 'yes');

        DELETE FROM ld_fieldwxdetailinfo WHERE tabid = @tabid;
        INSERT INTO ld_fieldwxdetailinfo ( tabid, relatedtable, columnname, sequence, mobiledetailinfoshowtype )
        VALUES
            (@tabid, 'ld_tabdetailfield', 'lin_users_id', 0, 'fold'),
            (@tabid, 'ld_tabdetailfield', 'budget_amount', 1, 'fold'),
            (@tabid, 'ld_tabdetailfield', 'description', 2, 'fold');

    END IF;
END ||
delimiter;

CALL addmobile_expensebudget();
delimiter;

ALTER TABLE ld_homeboard_plate_setting MODIFY COLUMN setvalue text;
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select "yes",486,'设置重要功能是否启用帮助手册入口 no:否，yes:是','',0,0,'select',1,'[{"value":"yes","text":"YES"},{"value":"no","text":"NO"},{"sql":""}]' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type = 486);
set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype=0 ORDER BY sequence;
delimiter;
-- 2024-08-16

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'leadsmassallocate','rely','批量分配','Allocate.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'leadsmassallocate');
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

DROP TRIGGER IF EXISTS `update_invoice_cashtotal_delete`;
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

UPDATE ld_version SET old_version='V8.6.4.2',current_version='V8.6.4.2',remark='V8.6.4.2-20240819',wx_version='V8.6.4.0';
delimiter;