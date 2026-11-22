DROP PROCEDURE IF EXISTS `ldcrm_addpermission_bytabaction`;
delimiter ||
CREATE PROCEDURE `ldcrm_addpermission_bytabaction`(
	tmp_profileid INT(19),
	tmp_modulename VARCHAR(100),
	tmp_actionname VARCHAR(100)
)
BEGIN

	SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=tmp_modulename);
	SET @actionid=(SELECT actionid FROM ld_actionmapping WHERE actionname=tmp_actionname);

	INSERT INTO ld_profile2tab(profileid,tabid,permissions) 
	SELECT tmp_profileid,@tabid,0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_profile2tab WHERE profileid=tmp_profileid AND tabid=@tabid);
	
	UPDATE ld_profile2tab SET permissions=0 WHERE profileid=tmp_profileid AND tabid=@tabid AND permissions=1;

	IF EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid AND operation=@actionid) THEN
		INSERT INTO ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
		SELECT tmp_profileid,tabid,operation,0,sequence FROM ld_profileallpermission WHERE tabid=@tabid AND operation=@actionid 
			AND NOT EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE profileid=tmp_profileid AND tabid=@tabid AND operation=@actionid);

		UPDATE ld_profile2standardpermissions SET permissions=0 WHERE profileid=tmp_profileid AND tabid=@tabid AND operation=@actionid;
	END IF;
	
end ||
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_allprofile_bytabaction`;
delimiter ||
CREATE PROCEDURE `ldcrm_allprofile_bytabaction`(
	tmp_modulename VARCHAR(100),
	tmp_actionname VARCHAR(100)
)
BEGIN
	
	DECLARE tmp_profileid INT(19) DEFAULT 0; 

	DECLARE MYCUSOR CURSOR FOR SELECT profileid FROM ld_profile;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_profileid = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_profileid;
	WHILE(tmp_profileid IS NOT NULL) DO
		CALL ldcrm_addpermission_bytabaction(tmp_profileid,tmp_modulename,tmp_actionname);
		FETCH MYCUSOR INTO tmp_profileid;
	END WHILE;
	CLOSE MYCUSOR;

end ||
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_rest_defaultprofile20180104`;
delimiter ||
CREATE PROCEDURE `ldcrm_rest_defaultprofile20180104`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_normalapprove) THEN
		CALL ldcrm_allprofile_bytabaction('NormalApprove','index');
		CALL ldcrm_allprofile_bytabaction('NormalApprove','DetailView');
		CALL ldcrm_allprofile_bytabaction('NormalApprove','Create');
		CALL ldcrm_allprofile_bytabaction('NormalApprove','Save');
		CALL ldcrm_allprofile_bytabaction('NormalApprove','EditView');
		CALL ldcrm_allprofile_bytabaction('NormalApprove','Copy');
		CALL ldcrm_allprofile_bytabaction('NormalApprove','Share');
	END IF;

	IF NOT EXISTS (SELECT 1 FROM ld_addjobbill) THEN 
		CALL ldcrm_allprofile_bytabaction('AddJobBill','index');
		CALL ldcrm_allprofile_bytabaction('AddJobBill','DetailView');
		CALL ldcrm_allprofile_bytabaction('AddJobBill','Create');
		CALL ldcrm_allprofile_bytabaction('AddJobBill','Save');
		CALL ldcrm_allprofile_bytabaction('AddJobBill','EditView');
		CALL ldcrm_allprofile_bytabaction('AddJobBill','Copy');
		CALL ldcrm_allprofile_bytabaction('AddJobBill','Share');
	END IF;

	IF NOT EXISTS (SELECT 1 FROM ld_minusjobbill) THEN 
		CALL ldcrm_allprofile_bytabaction('MinusJobBill','index');
		CALL ldcrm_allprofile_bytabaction('MinusJobBill','DetailView');
		CALL ldcrm_allprofile_bytabaction('MinusJobBill','Create');
		CALL ldcrm_allprofile_bytabaction('MinusJobBill','Save');
		CALL ldcrm_allprofile_bytabaction('MinusJobBill','EditView');
		CALL ldcrm_allprofile_bytabaction('MinusJobBill','Copy');
		CALL ldcrm_allprofile_bytabaction('MinusJobBill','Share');
	END IF;

	IF NOT EXISTS (SELECT 1 FROM ld_businessapply) THEN 
		CALL ldcrm_allprofile_bytabaction('BusinessApply','index');
		CALL ldcrm_allprofile_bytabaction('BusinessApply','DetailView');
		CALL ldcrm_allprofile_bytabaction('BusinessApply','Create');
		CALL ldcrm_allprofile_bytabaction('BusinessApply','Save');
		CALL ldcrm_allprofile_bytabaction('BusinessApply','EditView');
		CALL ldcrm_allprofile_bytabaction('BusinessApply','Copy');
		CALL ldcrm_allprofile_bytabaction('BusinessApply','Share');
	END IF;

	IF NOT EXISTS (SELECT 1 FROM ld_loanapply) THEN 
		CALL ldcrm_allprofile_bytabaction('LoanApply','index');
		CALL ldcrm_allprofile_bytabaction('LoanApply','DetailView');
		CALL ldcrm_allprofile_bytabaction('LoanApply','Create');
		CALL ldcrm_allprofile_bytabaction('LoanApply','Save');
		CALL ldcrm_allprofile_bytabaction('LoanApply','EditView');
		CALL ldcrm_allprofile_bytabaction('LoanApply','Copy');
		CALL ldcrm_allprofile_bytabaction('LoanApply','Share');
	END IF;

	IF NOT EXISTS (SELECT 1 FROM ld_cardapply) THEN 
		CALL ldcrm_allprofile_bytabaction('CardApply','index');
		CALL ldcrm_allprofile_bytabaction('CardApply','DetailView');
		CALL ldcrm_allprofile_bytabaction('CardApply','Create');
		CALL ldcrm_allprofile_bytabaction('CardApply','Save');
		CALL ldcrm_allprofile_bytabaction('CardApply','EditView');
		CALL ldcrm_allprofile_bytabaction('CardApply','Copy');
		CALL ldcrm_allprofile_bytabaction('CardApply','Share');
	END IF;

end ||
delimiter;

CALL ldcrm_rest_defaultprofile20180104();
DROP PROCEDURE IF EXISTS `ldcrm_rest_defaultprofile20180104`;
delimiter;

SET @lable='LBI_UI_SETTINGS';
SET @zh='界面设置';
SET @en='UI Settings';
SET @blockid=(SELECT max(blockid) FROM ld_settings_blocks);
UPDATE ld_settings_blocks SET sequence=sequence+1;
INSERT INTO ld_settings_blocks(blockid,label,sequence,active)
SELECT @blockid+1,@lable,1,0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_settings_blocks WHERE label=@lable);

SET @i=0;
UPDATE ld_settings_blocks SET sequence=(@i:=@i+1) ORDER BY sequence;

UPDATE ld_settings_blocks_seq SET id=(SELECT max(blockid) FROM ld_settings_blocks);

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@lable,@zh,'fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol=@lable AND labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@lable,@en,'fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol=@lable AND labeltype='fixedstr');
delimiter;

SET @i=0;
SET @j=0;
SET @blockid=(SELECT blockid FROM ld_settings_blocks WHERE label='LBI_UI_SETTINGS');
UPDATE ld_settings_field SET sequence=sequence+10 WHERE blockid=@blockid;
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='VTLIB_LBL_MODULE_MANAGER';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_PAGE_SET';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_ProductTool_field';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_TABLIST';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='MobileAppMenuCustomization';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='MobileAppDataListCustomization';

UPDATE ld_settings_field SET sequence=(@j:=@j+1) WHERE blockid=@blockid ORDER BY sequence;
delimiter;

SET @j=0;
SET @blockid=(SELECT blockid FROM ld_settings_blocks WHERE label='LBL_SYSTEM_SETTINGS');
UPDATE ld_settings_field SET sequence=(@j:=@j+1) WHERE blockid=@blockid ORDER BY sequence;
delimiter;

UPDATE ld_desk SET fieldlabel='WEB端菜单定制' WHERE labelbol='LBL_TABLIST' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='移动端菜单定制' WHERE labelbol='MobileAppMenuCustomization' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='移动端模块列表定制' WHERE labelbol='MobileAppDataListCustomization' AND languagetype='zh';

UPDATE ld_field SET defaultvalue=NULL WHERE uitype=15 AND presence<>1 AND quickcreate IN (1,3)
	AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);
-- 2018-01-04

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
update ld_relatedlists set actions = 'add' where tabid = @tabid and `name` = 'get_purchasecashback';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PICTUREFORMAT','：jpg，jpeg，bmp，png.icon，gif，dwg，psd，ico','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'PICTUREFORMAT' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PICTUREFORMAT',":jpg,jpeg,bmp,png.icon,gif,dwg,psd,ico",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'PICTUREFORMAT' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TEMPORARYTIPS','暂存后还可重新进行库存初始化，并且其他单据不会改变产品的初始化数量','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TEMPORARYTIPS' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TEMPORARYTIPS',"Storage can also be reinitialized after the temporary storage, and other documents will not change the number of initialization of the product",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TEMPORARYTIPS' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Save_and_confirm_TIPS','结束初始化后不可重新库存初始化，可通过其他单据修改产品的数量','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Save_and_confirm_TIPS' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Save_and_confirm_TIPS',"The initialization can not be reinitialized after the end of the initialization, and the number of products can be modified by other documents.",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Save_and_confirm_TIPS' and labeltype = 'fixedstr');
delimiter;

select max(fieldid) into @fieldid from ld_settings_field ;
select blockid into @blockid from ld_settings_blocks where label='LBL_SYSTEM_SETTINGS';
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @fieldid+1,@blockid,'LBL_PAGE_SET','iconpath.png','LBL_PAGE_SET_DESCRIPTION','index.php?module=Settings&action=ModuleSettings&parenttab=Settings',3,0
from dual where not exists(select 1 from ld_settings_field where linkto like '%action=ModuleSettings%');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CURTOTALPAGE','本页合计','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='CURTOTALPAGE' and Labeltype='fixedstr' and languagetype='zh');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CURTOTALPAGE','This page total','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='en' and Labeltype='fixedstr' and languagetype='zh');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLTOTALPAGE','全部合计','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='ALLTOTALPAGE' and Labeltype='fixedstr' and languagetype='zh');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLTOTALPAGE','All total','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='en' and Labeltype='fixedstr' and languagetype='zh');
delimiter;

update ld_dashboard_app set wx_sequence=2 where name='Salesfunnel';
set @i=0;
update ld_dashboard_app set wx_sequence=(@i:=@i+1) where wx_presence=1 order by wx_sequence;
delimiter;

update ld_desk set fieldlabel = '显示停用成员' where languagetype = 'zh' and labelbol = 'LBL_VIEWDISABLEUSER' and Labeltype = 'jspop';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Job','在职','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Job' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Job','Job','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Job' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Quit','离职','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Quit' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Quit','Quit','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Quit' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','membermanagement','成员管理','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'membermanagement' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','membermanagement','Member management','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'membermanagement' and labeltype = 'fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'viewothers';
update ld_tranlabel set fieldlabel = '查看其他成员单据' where tabid = @tabid and Relateid = @fieldid and trantable = 'ld_field' and languagetype = 'zh';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'editothers';
update ld_tranlabel set fieldlabel = '编辑其他成员单据' where tabid = @tabid and Relateid = @fieldid and trantable = 'ld_field' and languagetype = 'zh';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'delothers';
update ld_tranlabel set fieldlabel = '删除其他成员单据' where tabid = @tabid and Relateid = @fieldid and trantable = 'ld_field' and languagetype = 'zh';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'edit_other_mobile';
update ld_tranlabel set fieldlabel = '编辑其他成员单据手机' where tabid = @tabid and Relateid = @fieldid and trantable = 'ld_field' and languagetype = 'zh';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
update ld_tranlabel set fieldlabel = '成员管理' where tabid = @tabid and Relateid = @tabid and trantable = 'ld_tab' and languagetype = 'zh';
delimiter;

update ld_desk set fieldlabel = '高级(按成员设置)' where languagetype = 'zh' and labelbol = 'CUSTOMIZETOUSERSETTING' and Labeltype = 'fixedstr';
delimiter;

update ld_userlevel set userlevel = '普通成员' where userlevel = '普通用户';
update ld_users set userlevel = '普通成员' where userlevel = '普通用户';
select tabid into @tabid from ld_tab where `name` = 'Users';
update ld_field set defaultvalue = '普通成员' where tabid = @tabid and columnname = 'userlevel' and defaultvalue = '普通用户';
delimiter;

UPDATE ld_desk SET fieldlabel = REPLACE ( fieldlabel, '用户', '成员') 
where labelbol not in ('USERNAME','FORUSERSLIMIT','LBL_SMS_USERINFO','PMWARMREMINDFORPASSWORD','PMPASSWORDILLEGALCONTAIN','USERNAMECANOTEMPTY');
delimiter;

update ld_relatedlists set related_coltable='tmp_related_cashbill.entitytypeid',type='sendcashbillsourcebill_datacategory'
where tabid=21 and name='get_SendCashBill';
delimiter;

update ld_desk set fieldlabel='新增分类' where labelbol='CREATECATEGORIES' and Labeltype='fixedstr' and languagetype='zh';
delimiter;

CALL AddColumn('ld_customview','description','varchar',100,NULL);
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_upgrade_customview`;
delimiter ||
CREATE PROCEDURE `ldcrm_upgrade_customview`(
)
BEGIN
	
	DECLARE tmp_cvid INT(19) DEFAULT 0; 
	DECLARE tmp_columnname TEXT DEFAULT '';
	DECLARE tmp_stdfilter VARCHAR(100) DEFAULT ''; 
	DECLARE tmp_startdate DATE DEFAULT NULL; 
	DECLARE tmp_enddate DATE DEFAULT NULL; 

	DECLARE MYCUSOR CURSOR FOR 
	SELECT
		a.cvid,
		b.columnname,
		b.stdfilter,
		b.startdate,
		b.enddate
	FROM ld_customview a
	INNER JOIN ld_cvstdfilter b ON a.cvid=b.cvid
	WHERE IFNULL(description,'')<>'done';
	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_cvid = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_cvid,tmp_columnname,tmp_stdfilter,tmp_startdate,tmp_enddate;
	WHILE(tmp_cvid IS NOT NULL) DO
		UPDATE ld_customview SET description='done' WHERE cvid=tmp_cvid;
		SET @groupid=IFNULL((SELECT MAX(groupid) FROM ld_cvadvfilter_grouping WHERE cvid=tmp_cvid),0);

		IF @groupid=0 THEN
			INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression) SELECT 1,tmp_cvid,'',0;
			
			DELETE FROM ld_cvadvfilter WHERE cvid=tmp_cvid;
			IF tmp_stdfilter='custom' THEN
				INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
				SELECT tmp_cvid,0,tmp_columnname,'bw',CONCAT(tmp_startdate,',',tmp_enddate),1,'';
			ELSE
				INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
				SELECT tmp_cvid,0,tmp_columnname,tmp_stdfilter,'',1,'';
			END IF;
		ELSE
			UPDATE ld_cvadvfilter_grouping SET group_condition='and' WHERE cvid=tmp_cvid AND groupid=@groupid;
			SET @seq=(SELECT MAX(condition_expression) FROM ld_cvadvfilter_grouping WHERE cvid=tmp_cvid);
			INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression) SELECT @groupid+1,tmp_cvid,'',@seq+1;
			SET @columnindex=(SELECT MAX(columnindex) FROM ld_cvadvfilter WHERE cvid=tmp_cvid);
			IF tmp_stdfilter='custom' THEN
				INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
				SELECT tmp_cvid,@columnindex+1,tmp_columnname,'bw',CONCAT(tmp_startdate,',',tmp_enddate),@groupid+1,'';
			ELSE
				INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
				SELECT tmp_cvid,@columnindex+1,tmp_columnname,tmp_stdfilter,'',@groupid+1,'';
			END IF;
		END IF;

		FETCH MYCUSOR INTO tmp_cvid,tmp_columnname,tmp_stdfilter,tmp_startdate,tmp_enddate;
	END WHILE;
	CLOSE MYCUSOR;

end ||
delimiter;

CALL ldcrm_upgrade_customview();
DROP PROCEDURE IF EXISTS `ldcrm_upgrade_customview`;

ALTER TABLE ld_users ALTER COLUMN is_admin SET DEFAULT 'off';
UPDATE ld_users SET is_admin='off' WHERE TRIM(IFNULL(is_admin,''))<>'on';

UPDATE ld_field SET masseditable=0 WHERE uitype IN (11,13,1101,1102);
UPDATE ld_relatedlists SET related_tabid=-1 WHERE `name`='get_WorkReport';
UPDATE ld_relatedlists SET presence=1 WHERE `name`='get_WorkReport' AND NOT EXISTS (SELECT 1 FROM ld_workreport);

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CONDITION','条件','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'CONDITION' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CONDITION',"conditions",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'CONDITION' and labeltype = 'fixedstr');
delimiter;

update ld_desk set fieldlabel='添加组合条件' where labelbol='NEWCOMBINATION' and Labeltype='fixedstr' and languagetype='zh';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VIEWTYPE','分类','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'VIEWTYPE' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','VIEWTYPE','Filters','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'VIEWTYPE' and labeltype = 'fixedstr');
delimiter;
-- 2018-01-05

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MODULERELSEVANT','相关','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'MODULERELSEVANT' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MODULERELSEVANT','Relevant','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'MODULERELSEVANT' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MAOHAO','：','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'MAOHAO' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MAOHAO',':','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'MAOHAO' and labeltype = 'fixedstr');
delimiter;

update ld_field set typeofdata='V~O' where tabid in(select tabid from ld_tab where name='purchaseback' ) and columnname='purchaseorder_id';
delimiter;

update ld_field set typeofdata='V~O' where tabid=22 and columnname='quoteid';
delimiter;

update ld_field set typeofdata='V~O' where tabid in(select tabid from ld_tab where name='SalesBack') and columnname='salesorderid';
delimiter;

DROP PROCEDURE IF EXISTS `update_fieldwxmaininfo_title`;
delimiter ||
CREATE  PROCEDURE `update_fieldwxmaininfo_title`(
)
begin

	declare tmp_tabid int(10) default 0;
	declare cur1 cursor for select distinct tabid from ld_fieldwxmaininfo;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_tabid = NULL;

	OPEN cur1;
	Fetch cur1 into tmp_tabid;
	while(tmp_tabid is not null) DO
		select fieldname into @tmp_fieldname from ld_entityname where tabid=tmp_tabid;
		INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
		SELECT tmp_tabid,@tmp_fieldname,0,'tagtitle' FROM DUAL
		WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=tmp_tabid AND fieldname=@tmp_fieldname);
		update ld_fieldwxmaininfo set displaytype='tagtitle',sequence=0 where tabid=tmp_tabid AND fieldname=@tmp_fieldname;
		set @i=0;
		update ld_fieldwxmaininfo set sequence=(@i:=@i+1) where tabid=tmp_tabid order by sequence;
		Fetch cur1 into tmp_tabid;
	end while;

	close cur1;

end ||
delimiter;

call update_fieldwxmaininfo_title();
delimiter;

DROP PROCEDURE IF EXISTS `update_fieldwxmaininfo_title`;
delimiter;

select tabid into @tabid from ld_tab where name='Commission';
update ld_fieldwxmaininfo set displaytype='normal' where tabid=@tabid;
update ld_fieldwxmaininfo set displaytype='title' where fieldname='assigned_user_id' and tabid=@tabid;
delimiter;

select tabid into @tabid from ld_tab where name='Expense';
update ld_fieldwxmaininfo set displaytype='normal' where tabid=@tabid;
update ld_fieldwxmaininfo set displaytype='title' where fieldname='assigned_user_id' and tabid=@tabid;
delimiter;

select tabid into @tabid from ld_tab where name='CardApply';
update ld_fieldwxmaininfo set displaytype='normal' where tabid=@tabid;
update ld_fieldwxmaininfo set displaytype='title' where fieldname='assigned_user_id' and tabid=@tabid;
delimiter;

select tabid into @tabid from ld_tab where name='BusinessApply';
update ld_fieldwxmaininfo set displaytype='normal' where tabid=@tabid;
update ld_fieldwxmaininfo set displaytype='title' where fieldname='assigned_user_id' and tabid=@tabid;
delimiter;

select tabid into @tabid from ld_tab where name='Accounts';
update ld_fieldwxmaininfo set displaytype='title' where fieldname='accountname' and tabid=@tabid;
delimiter;

select tabid into @tabid from ld_tab where name='ContactRecords';
update ld_fieldwxmaininfo set displaytype='normal' where tabid=@tabid;
update ld_fieldwxmaininfo set displaytype='title' where fieldname='account_id' and tabid=@tabid;
delimiter;

select tabid into @tabid from ld_tab where name='Potentials';
update ld_fieldwxmaininfo set displaytype='normal' where tabid=@tabid;
update ld_fieldwxmaininfo set displaytype='title' where fieldname='account_id' and tabid=@tabid;
delimiter;

select tabid into @tabid from ld_tab where name='Invoice';
update ld_fieldwxmaininfo set displaytype='normal' where tabid=@tabid;
update ld_fieldwxmaininfo set displaytype='title' where fieldname='account_id' and tabid=@tabid;
delimiter;

select tabid into @tabid from ld_tab where name='CashBill';
update ld_fieldwxmaininfo set displaytype='normal' where tabid=@tabid;
update ld_fieldwxmaininfo set displaytype='title' where fieldname='account_id' and tabid=@tabid;
delimiter;

select tabid into @tabid from ld_tab where name='SalesOrder';
update ld_fieldwxmaininfo set displaytype='normal' where tabid=@tabid;
update ld_fieldwxmaininfo set displaytype='title' where fieldname='account_id' and tabid=@tabid;
delimiter;

select tabid into @tabid from ld_tab where name='Contacts';
update ld_fieldwxmaininfo set displaytype='normal' where tabid=@tabid;
update ld_fieldwxmaininfo set displaytype='title' where fieldname='account_id' and tabid=@tabid;
delimiter;

select tabid into @tabid from ld_tab where name='Products';
update ld_fieldwxmaininfo set displaytype='title' where fieldname='productname' and tabid=@tabid;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WARMPROMPT','温馨提示','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'WARMPROMPT' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WARMPROMPT','Warm prompt','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'WARMPROMPT' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WENHAO','？','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'WENHAO' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WENHAO','?','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'WENHAO' and labeltype = 'jspop');
delimiter;

delete from  ld_relatedlists  where related_tabid=-11;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select  'zh','PRINTTOOL','打印工具','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PRINTTOOL' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select  'en','PRINTTOOL','Printing tool','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PRINTTOOL' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select  'zh','CHOOSEOPERATE','选择操作','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CHOOSEOPERATE' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select  'en','CHOOSEOPERATE','Choose  Operate','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CHOOSEOPERATE' and labeltype='fixedstr');
delimiter;
-- 2018-01-08

update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
update ld_customview_seq set id = (select max(cvid) from ld_customview);
update ld_links_seq set id=(select max(linkid) from ld_links);
update ld_picklist_dependency_seq set id=(select max(id) from ld_picklist_dependency);
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
update ld_approve_seq set id=(select max(id) from ld_approve);
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
update ld_autotask_seq set id = (select MAX(autotaskid) from ld_autotask);
update ld_currency_info_seq set id=(select max(id) from ld_currency_info);
update ld_users_seq set id=(select max(id) from ld_users);
update ld_tabdetailfield_seq set id=(select max(tabdetailfieldid) from ld_tabdetailfield);
update ld_customreport_info_seq set id=(select max(report_id) from ld_customreport_info);
update ld_producttoolfield_seq set id=(select MAX(producttoolfieldid) from ld_producttoolfield);
UPDATE ld_settings_field_seq SET id=(SELECT max(fieldid) FROM ld_settings_field);
delimiter;

update ld_version set old_version='V7.1.9',current_version='V7.1.9',remark='V7.1.9-20180108',wx_version='V7.1.9';
delimiter;