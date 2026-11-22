UPDATE ld_tabdetailfield SET width=40 WHERE columnname='expenseuse' AND tablename='ld_expensedetail' AND width=35;

CREATE TABLE IF NOT EXISTS `ld_version_firstlogin` (
  `versiontype` int(11) DEFAULT NULL,
  `first_logintime` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

DROP PROCEDURE IF EXISTS `Init_ld_version_firstlogin`;
delimiter ||
CREATE  PROCEDURE `Init_ld_version_firstlogin`(
)
BEGIN
	
	SET @versiontype=(SELECT versiontype FROM ld_version LIMIT 1);
	
	IF @versiontype IN (55,56,57) AND EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>5) THEN 
		INSERT INTO ld_version_firstlogin(versiontype,first_logintime)
		SELECT @versiontype,NOW() FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_version_firstlogin WHERE versiontype=@versiontype);
	ELSEIF @versiontype NOT IN (55,56,57) AND EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2) THEN
		INSERT INTO ld_version_firstlogin(versiontype,first_logintime)
		SELECT @versiontype,NOW() FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_version_firstlogin WHERE versiontype=@versiontype);
	END IF;
end ||
delimiter;


CALL Init_ld_version_firstlogin;
DROP PROCEDURE IF EXISTS `Init_ld_version_firstlogin`;
delimiter;
-- 2018-01-02

DELETE FROM ld_parenttab WHERE parenttab_label IN ('Journal','Expense','Asset','Inventroy') AND visible=5;
SET @blockid=(SELECT blockid FROM ld_settings_blocks WHERE label='LBL_OTHER_SETTINGS');
DELETE FROM ld_settings_field WHERE blockid=@blockid AND `name`='LBL_SMS_SETTINGS';

DELETE FROM ld_settings_field WHERE `name`='LBL_PAGE_SET';
SET @blockid=(SELECT blockid FROM ld_settings_blocks WHERE label='LBL_SYSTEM_SETTINGS');
SET @fieldid=(SELECT max(fieldid) FROM ld_settings_field);
SET @seq=(SELECT sequence FROM ld_settings_field WHERE `name`='VTLIB_LBL_MODULE_MANAGER');
UPDATE ld_settings_field SET sequence=sequence+1 WHERE blockid=@blockid AND sequence>@seq;
INSERT INTO ld_settings_field(fieldid,blockid,`name`,iconpath,description,linkto,sequence,active)
SELECT @fieldid+1,@blockid,'LBL_PAGE_SET','pageset.png','LBL_PAGE_SET_DESCRIPTION','index.php?module=Settings&action=ModuleSettings&parenttab=Settings',@seq+1,0;

SET @i=0;
UPDATE ld_settings_field SET sequence=(@i:=@i+1) WHERE blockid=@blockid ORDER BY sequence;
delimiter;

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
-- 2018-01-03

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

update ld_version set old_version='V7.1.8',current_version='V7.1.8',remark='V7.1.8-20180103',wx_version='V7.1.8';
delimiter;