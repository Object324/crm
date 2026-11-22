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

delete from ld_relatedlists where tabid>0 and name='get_singin';
delimiter;

call AddColumn('ld_appuiset','tab_tablename','varchar',100,null );
delimiter;

UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_huanbi_Salesorder.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_huanbi_SalesorderQty.mrt';

UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_callcenter_report.mrt';
UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_callcenter_detail.mrt';

UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='default_huanbi_paymentQty.mrt';
UPDATE ld_customreport_info SET report_type='template_js',report_template='default_huanbi_Salesorder.mrt' WHERE report_template='default_huanbi_paySalesorder.mrt';
-- 2019-11-07

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOConvertNormalPermitter','公海已分配{$Accounts.Accounts}不允许转普通（只能由公海管理员转普通）','fixedstr' from dual 
where not exists(select 1 from ld_desk where labeltype='fixedstr' and labelbol='NOConvertNormalPermitter' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOConvertNormalPermitter','The allocated unassigned customers are not allowed to turn to normal(Only can be turn to normal by administrators)','fixedstr' from dual 
where not exists(select 1 from ld_desk where labeltype='fixedstr' and labelbol='NOConvertNormalPermitter' and languagetype='en');
delimiter;

CALl AddColumn('ld_account_set','normalconvertbuttonprofile','varchar','50','yes');
delimiter;

update ld_account_set set normalconvertbuttonprofile='yes' 
where normalconvertbuttonprofile is null or normalconvertbuttonprofile='';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ConvertNormaaccountFailure','单据[%s]转为普通客户失败！原因：您没有该单据的转普通权限！','fixedstr' from dual 
where not exists(select 1 from ld_desk where labeltype='fixedstr' and labelbol='ConvertNormaaccountFailure' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ConvertNormaaccountFailure','Document[%s] turn to normal customer no success! The reason: you do not have the permissions to turn to normal the document!','fixedstr' from dual 
where not exists(select 1 from ld_desk where labeltype='fixedstr' and labelbol='ConvertNormaaccountFailure' and languagetype='en');
delimiter;

SET @i=0;
SET @listid=(SELECT listid FROM ld_picklist_set WHERE listname='industry');

UPDATE ld_picklist_values SET sequence=sequence+1 WHERE listid=@listid;
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,'IT',1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@listid AND listvalue='IT')
	AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>6);

UPDATE ld_picklist_values SET sequence=(@i:=@i+1) WHERE listid=@listid ORDER BY sequence;
delimiter;

UPDATE ld_dashboard_app SET modulenames='CooperativeWork' WHERE `name` IN ('weeklog','monthlog');
UPDATE ld_dashboard_app SET modulenames='Products' WHERE `name` IN ('InventoryQuery');
UPDATE ld_dashboard_app SET modulenames='' WHERE `name` IN ('monthweekreport');
UPDATE ld_dashboard_app SET modulenames='Accounts,Potentials,SalesOrder,ServiceContracts' WHERE `name` IN ('Saleskit');


SELECT max(relation_id) INTO @id FROM ld_relatedlists;
SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Accounts';
SELECT MAX(sequence) INTO @sequence FROM ld_relatedlists WHERE tabid = @tabid;
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,actions)
SELECT @id+1,@tabid,0,'get_singin',@sequence+1,'Singin',''
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists  WHERE tabid = @tabid AND NAME = 'get_singin');
UPDATE ld_relatedlists_seq SET id = (SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;

create table if not exists `ld_mobile_report_parent_tab`(
  `block_id` int(19) auto_increment primary key comment '移动端报表菜单定制区块表主键',
  `block_name` varchar(255)  comment '区块中文名称',
  `presence` int(4) comment '开关：0 启用 1 不启用',
  `sequence` int(4)  comment '顺序',
  `systemdefault` varchar(100) comment '是否是系统默认区块',
  `parenttab_label` varchar(255) comment '区间名称',
  `allocatetype` varchar(255) comment '可见范围类型',
  `allocateid` varchar(255) comment '可见范围'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

create table if not exists `ld_mobile_report_tab_rel`(
  `id` int(19) auto_increment primary key comment '移动端报表菜单定制区块关联表主键',
  `block_id` int(19)  comment '移动端报表菜单定制区块表外键',
  `tabid` varchar(255)  comment '报表ID',
  `sequence` int(4)  comment '顺序',
  `tab_tablename` varchar(100) comment '是否是系统默认区块'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_mobile_report_parent_tab ( block_name, presence, sequence, systemdefault,
                                          parenttab_label, allocatetype, allocateid) select '销售报表',0,1,'yes','sales','all','' from dual
where not exists(select 1 from ld_mobile_report_parent_tab where parenttab_label='sales') ;
insert into ld_mobile_report_parent_tab ( block_name, presence, sequence, systemdefault,
                                          parenttab_label, allocatetype, allocateid) select '库存报表',0,2,'yes','inventory','all','' from dual
where not exists(select 1 from ld_mobile_report_parent_tab where parenttab_label='inventory') ;
insert into ld_mobile_report_parent_tab ( block_name, presence, sequence, systemdefault,
                                          parenttab_label, allocatetype, allocateid) select '统计图表',0,3,'yes','statistical','all','' from dual
where not exists(select 1 from ld_mobile_report_parent_tab where parenttab_label='statistical') ;
insert into ld_mobile_report_parent_tab ( block_name, presence, sequence, systemdefault,
                                          parenttab_label, allocatetype, allocateid) select '统计排名',0,4,'yes','rank','all','' from dual
where not exists(select 1 from ld_mobile_report_parent_tab where parenttab_label='rank') ;
insert into ld_mobile_report_parent_tab ( block_name, presence, sequence, systemdefault,
                                          parenttab_label, allocatetype, allocateid) select '数据报表',0,5,'yes','data','all','' from dual
where not exists(select 1 from ld_mobile_report_parent_tab where parenttab_label='data') ;

select block_id into @block_id from ld_mobile_report_parent_tab where parenttab_label='data';
select id into @reportid from ld_dashboard_app where name = 'daylog';
insert into ld_mobile_report_tab_rel (block_id, tabid, sequence, tab_tablename)
  select @block_id,@reportid,1,'ld_tab'
  from dual where not exists(select 1 from ld_mobile_report_tab_rel where block_id=@block_id and tabid=@reportid);
select id into @reportid from ld_dashboard_app where name = 'weeklog';
insert into ld_mobile_report_tab_rel (block_id, tabid, sequence, tab_tablename)
  select @block_id,@reportid,2,'ld_tab'
  from dual where not exists(select 1 from ld_mobile_report_tab_rel where block_id=@block_id and tabid=@reportid);
select id into @reportid from ld_dashboard_app where name = 'monthlog';
insert into ld_mobile_report_tab_rel (block_id, tabid, sequence, tab_tablename)
  select @block_id,@reportid,3,'ld_tab'
  from dual where not exists(select 1 from ld_mobile_report_tab_rel where block_id=@block_id and tabid=@reportid);

select block_id into @block_id from ld_mobile_report_parent_tab where parenttab_label='rank';
select id into @reportid from ld_dashboard_app where name = 'signednumber';
insert into ld_mobile_report_tab_rel (block_id, tabid, sequence, tab_tablename)
  select @block_id,@reportid,1,'ld_tab'
  from dual where not exists(select 1 from ld_mobile_report_tab_rel where block_id=@block_id and tabid=@reportid);
select id into @reportid from ld_dashboard_app where name = 'signedamount';
insert into ld_mobile_report_tab_rel (block_id, tabid, sequence, tab_tablename)
  select @block_id,@reportid,2,'ld_tab'
  from dual where not exists(select 1 from ld_mobile_report_tab_rel where block_id=@block_id and tabid=@reportid);
select id into @reportid from ld_dashboard_app where name = 'cashbillamount';
insert into ld_mobile_report_tab_rel (block_id, tabid, sequence, tab_tablename)
  select @block_id,@reportid,3,'ld_tab'
  from dual where not exists(select 1 from ld_mobile_report_tab_rel where block_id=@block_id and tabid=@reportid);

select block_id into @block_id from ld_mobile_report_parent_tab where parenttab_label='statistical';
select id into @reportid from ld_dashboard_app where name = 'Contractamount';
insert into ld_mobile_report_tab_rel (block_id, tabid, sequence, tab_tablename)
  select @block_id,@reportid,1,'ld_tab'
  from dual where not exists(select 1 from ld_mobile_report_tab_rel where block_id=@block_id and tabid=@reportid);
select id into @reportid from ld_dashboard_app where name = 'Returnamount';
insert into ld_mobile_report_tab_rel (block_id, tabid, sequence, tab_tablename)
  select @block_id,@reportid,2,'ld_tab'
  from dual where not exists(select 1 from ld_mobile_report_tab_rel where block_id=@block_id and tabid=@reportid);
select id into @reportid from ld_dashboard_app where name = 'Salessituation';
insert into ld_mobile_report_tab_rel (block_id, tabid, sequence, tab_tablename)
  select @block_id,@reportid,3,'ld_tab'
  from dual where not exists(select 1 from ld_mobile_report_tab_rel where block_id=@block_id and tabid=@reportid);
select id into @reportid from ld_dashboard_app where name = 'Accountleadsource';
insert into ld_mobile_report_tab_rel (block_id, tabid, sequence, tab_tablename)
  select @block_id,@reportid,4,'ld_tab'
  from dual where not exists(select 1 from ld_mobile_report_tab_rel where block_id=@block_id and tabid=@reportid);
select id into @reportid from ld_dashboard_app where name = 'expense_commission';
insert into ld_mobile_report_tab_rel (block_id, tabid, sequence, tab_tablename)
  select @block_id,@reportid,5,'ld_tab'
  from dual where not exists(select 1 from ld_mobile_report_tab_rel where block_id=@block_id and tabid=@reportid);

select block_id into @block_id from ld_mobile_report_parent_tab where parenttab_label='inventory';
select id into @reportid from ld_dashboard_app where name = 'InventoryQuery';
insert into ld_mobile_report_tab_rel (block_id, tabid, sequence, tab_tablename)
  select @block_id,@reportid,1,'ld_tab'
  from dual where not exists(select 1 from ld_mobile_report_tab_rel where block_id=@block_id and tabid=@reportid);

select block_id into @block_id from ld_mobile_report_parent_tab where parenttab_label='sales';
select id into @reportid from ld_dashboard_app where name = 'Contractkit';
insert into ld_mobile_report_tab_rel (block_id, tabid, sequence, tab_tablename) select @block_id,@reportid,1,'ld_tab'
                                                                                from dual where not exists(select 1 from ld_mobile_report_tab_rel where block_id=@block_id and tabid=@reportid);
select id into @reportid from ld_dashboard_app where name = 'Saleskit';
insert into ld_mobile_report_tab_rel (block_id, tabid, sequence, tab_tablename) select @block_id,@reportid,2,'ld_tab'
                                                                                from dual where not exists(select 1 from ld_mobile_report_tab_rel where block_id=@block_id and tabid=@reportid);
select id into @reportid from ld_dashboard_app where name = 'Salesfunnel';
insert into ld_mobile_report_tab_rel (block_id, tabid, sequence, tab_tablename)
  select @block_id,@reportid,3,'ld_tab'
  from dual where not exists(select 1 from ld_mobile_report_tab_rel where block_id=@block_id and tabid=@reportid);
select id into @reportid from ld_dashboard_app where name = 'SalesOrderTrack';
insert into ld_mobile_report_tab_rel (block_id, tabid, sequence, tab_tablename)
  select @block_id,@reportid,4,'ld_tab'
  from dual where not exists(select 1 from ld_mobile_report_tab_rel where block_id=@block_id and tabid=@reportid);
select id into @reportid from ld_dashboard_app where name = 'CashBillSum_SalesOrder';
insert into ld_mobile_report_tab_rel (block_id, tabid, sequence, tab_tablename)
  select @block_id,@reportid,5,'ld_tab'
  from dual where not exists(select 1 from ld_mobile_report_tab_rel where block_id=@block_id and tabid=@reportid);
select id into @reportid from ld_dashboard_app where name = 'CashBillSum_Paymentplan';
insert into ld_mobile_report_tab_rel (block_id, tabid, sequence, tab_tablename)
  select @block_id,@reportid,6,'ld_tab'
  from dual where not exists(select 1 from ld_mobile_report_tab_rel where block_id=@block_id and tabid=@reportid);

UPDATE ld_desk SET fieldlabel='定制移动端底部导航功能菜单CRM的界面布局样式' WHERE labelbol='Customiseinterfacelayoutofmobileapplication' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='Customize the interface layout style of CRM for the navigation function menu at the bottom of the mobile terminal'
WHERE labelbol='Customiseinterfacelayoutofmobileapplication' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='移动端功能菜单定制' WHERE labelbol='MobileAppMenuCustomization' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='Mobile terminal function menu customization' WHERE labelbol='MobileAppMenuCustomization' AND languagetype='en';

select max(fieldid) into @fieldid from ld_settings_field ;
select blockid into @blockid from ld_settings_blocks where label='LBI_UI_SETTINGS';
select sequence into @sequence from ld_settings_field where blockid=@blockid and name='MobileAppMenuCustomization';
update ld_settings_field set sequence=sequence+1 where sequence > @sequence;
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
  select @fieldid+1,@blockid,'report_menu_customization','picklistdependency.png','report_menu_customization_describ',
    'index.php?module=Settings&action=reportMenuCustomization&parenttab=Settings',@sequence+1,0 from DUAL
  where not exists(select 1 from ld_settings_field where blockid = @blockid and `name` = 'report_menu_customization');
set @i =0 ;
update ld_settings_field set sequence=(@i:=@i+1) where blockid=@blockid order by sequence asc;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','report_menu_customization','移动端报表菜单定制','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'report_menu_customization' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','report_menu_customization','Mobile report menu customization','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'report_menu_customization' and languagetype='en' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','report_menu_customization_describ','定制移动端底部导航报表菜单CRM的界面布局样式','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'report_menu_customization_describ' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','report_menu_customization_describ','Customize the interface layout style of CRM for the navigation report menu at the bottom of the mobile terminal','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'report_menu_customization_describ' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
-- 2019-11-08

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

UPDATE ld_version SET old_version='V7.9.5',current_version='V7.9.5',remark='V7.9.5-20191108',wx_version='V7.9.5';
delimiter;